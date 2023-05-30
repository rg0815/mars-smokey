using System.Collections.Concurrent;
using backend_user_service.Repositories;
using Google.Protobuf.Collections;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using NLog;
using ssds_user_update;

namespace backend_user_service.Service;

public class UserServiceServer : UserUpdateService.UserUpdateServiceBase
{
    private static readonly ConcurrentDictionary<string, Tuple<IServerStreamWriter<UserUpdate>, ServerCallContext>>
        Subscriptions = new();

    private readonly UserRepository _userRepository;
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public UserServiceServer(UserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public override async Task<Task> Subscribe(Request request, IServerStreamWriter<UserUpdate> responseStream,
        ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.CompletedTask;
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.CompletedTask;
        }

        while (!context.CancellationToken.IsCancellationRequested)
        {
            var users = _userRepository.GetUsers();
            if (users.Any())
            {
                var last = users.Last();
                foreach (var user in users)
                {
                    var read = new RepeatedField<string>();
                    read.AddRange(user.ReadAccess);
                    var write = new RepeatedField<string>();
                    write.AddRange(user.WriteAccess);

                    var update = new UserUpdate
                    {
                        Id = user.Id,
                        Email = user.Email,
                        TenantId = user.TenantId.ToString(),
                        IsSuperAdmin = user.IsSuperAdmin,
                        IsTenantAdmin = user.IsTenantAdmin,
                        ReadAccess = { read },
                        WriteAccess = { write },
                        LastUpdated = Timestamp.FromDateTime(DateTime.UtcNow)
                    };

                    if (user.Id == last.Id)
                    {
                        Subscriptions.TryAdd(request.Id,
                            new Tuple<IServerStreamWriter<UserUpdate>, ServerCallContext>(responseStream, context));
                        await responseStream.WriteAsync(update);
                    }

                    await responseStream.WriteAsync(update);
                }
            }

            //keep the connection alive
            while (true)
            {
            }
        }

        return responseStream.WriteAsync(new UserUpdate());
    }

    public static async Task Broadcast(UserUpdate userUpdate)
    {
        foreach (var subscription in Subscriptions)
        {
            try
            {
                if (subscription.Value.Item2.Status.StatusCode != StatusCode.OK)
                {
                    Subscriptions.Remove(subscription.Key, out _);
                }
                else if (subscription.Value.Item2.Status.StatusCode == StatusCode.OK)
                {
                    try
                    {
                        await subscription.Value.Item1.WriteAsync(userUpdate);
                    }
                    catch (Exception e)
                    {
                        if (e is InvalidOperationException &&
                            e.Message == "Can't write the message because the request is complete.")
                        {
                            Subscriptions.Remove(subscription.Key, out _);
                            Logger.Info("Subscription removed");
                        }
                        else
                            Logger.Error(e);
                    }
                }
            }
            catch (Exception e)
            {
                Logger.Error(e);
            }
        }
    }
}