using backend_system_service.Helper;
using Grpc.Core;
using Grpc.Net.Client;
using NLog;
using ssds_user_update;

namespace backend_system_service.Services;

public static class UserServiceClient
{
    private static Thread? _thread;
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private const string UserServiceUrl = "http://localhost:82";

    private static void GetUsers()
    {
        try
        {
            var handler = new SocketsHttpHandler()
            {
                PooledConnectionIdleTimeout = Timeout.InfiniteTimeSpan,
                PooledConnectionLifetime = Timeout.InfiniteTimeSpan,
                KeepAlivePingDelay = TimeSpan.FromSeconds(60),
                KeepAlivePingTimeout = TimeSpan.FromSeconds(30),
                EnableMultipleHttp2Connections = true
            };

            var channel = GrpcChannel.ForAddress(UserServiceUrl, new GrpcChannelOptions
            {
                HttpHandler = handler
            });

            var client = new UserUpdateService.UserUpdateServiceClient(channel);
            var res = client.Subscribe(new Request() { Id = "SystemBackend" }, GetHeaders());

            while (res.ResponseStream.MoveNext(new CancellationToken()).Result)
            {
                var user = res.ResponseStream.Current;
                Logger.Info($"Received user update: {user.Id}");
                if (!Guid.TryParse(user.Id, out var guid))
                {
                    Logger.Error("Could not parse user guid: " + user.Id);
                    continue;
                }                
                
                var roleModel = new UserModel()
                {
                    Name = user.Name,
                    IsSuperAdmin = user.IsSuperAdmin,
                    IsTenantAdmin = user.IsTenantAdmin,
                    TenantId = Guid.Parse(user.TenantId),
                    UserId = guid,
                    Email = user.Email,
                    WriteBuildingUnitIds = user.WriteAccess.Select(Guid.Parse).ToList(),
                    ReadBuildingUnitIds = user.ReadAccess.Select(Guid.Parse).ToList(),
                    PhoneNumber = user.PhoneNumber,
                };

                if (PermissionHelper.Roles.ContainsKey(user.Id))
                    PermissionHelper.Roles[user.Id] = roleModel;
                else
                    PermissionHelper.Roles.TryAdd(user.Id, roleModel);

                //
                // var options = new DbContextOptions<DatabaseContext>();
                // var notificationRepository = new GenericRepository<NotificationSetting>(new DatabaseContext(options));
                //
                // var noti = notificationRepository.GetByCondition(x => x.UserId == Guid.Parse(user.Id) || x.Email == user.Email);
                // if (noti == null)
                // {
                //     noti = new NotificationSetting()
                //     {
                //         Name = user.Name,
                //         Email = user.Email,
                //         UserId = guid,
                //         EmailNotification = true,
                //         SmsNotification = false,
                //         PushNotification = false,
                //         HttpNotification = false,
                //         PhoneCallNotification = false,
                //         PhoneNumber = user.PhoneNumber,
                //         HttpNotifications = new List<HttpNotification>(),
                //         PushNotificationTokens = new List<PushNotificationToken>(),
                //         SMSNumber = user.PhoneNumber
                //     };
                //
                //     notificationRepository.Insert(noti);
                // }
            }

            if (res.GetStatus().StatusCode != StatusCode.OK)
            {
                Logger.Error($"Error while receiving user updates: {res.GetStatus().Detail}");
            }

            Logger.Info("Stopped thread to receive user updates");
        }
        catch (Exception e)
        {
            Logger.Error(e);
        }
    }

    private static Metadata GetHeaders()
    {
        var metadata = new Metadata();
        var key = Program.JwtSettings.BackendValidationKey;
        if (key == null) throw new Exception("No key found");
        metadata.Add("x-custom-backend-auth", key);
        return metadata;
    }

    public static void StartThread()
    {
        var thread = new Thread(RuntimeChecker);
        thread.Start();
    }

    private static void RuntimeChecker()
    {
        while (true)
        {
            if (_thread == null || _thread.IsAlive == false)
            {
                _thread = new Thread(GetUsers);
                _thread.Start();
                Logger.Info("Started thread to receive user updates");
            }

            Thread.Sleep(3000);
        }
        // ReSharper disable once FunctionNeverReturns
    }
}