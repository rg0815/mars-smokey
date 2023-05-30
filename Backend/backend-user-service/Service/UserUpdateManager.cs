using Core.Entities;
using Google.Protobuf.Collections;
using Google.Protobuf.WellKnownTypes;
using NLog;
using ssds_user_update;

namespace backend_user_service.Service;

public static class UserUpdateManager
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private static readonly List<UserUpdate> UpdateQueue = new();
    private static readonly ManualResetEvent RunningSignal = new(false);
    private static readonly ManualResetEvent StopSignal = new(false);

    public static bool AddUserUpdate(AppUser user, bool isNew)
    {
        try
        {
            var read = new RepeatedField<string>();
            read.AddRange(user.ReadAccess);
            var write = new RepeatedField<string>();
            write.AddRange(user.WriteAccess);
            var userUpdate = new UserUpdate()
            {
                Id = user.Id,
                TenantId = user.TenantId.ToString(),
                IsSuperAdmin = user.IsSuperAdmin,
                IsTenantAdmin = user.IsTenantAdmin,
                ReadAccess = {read},
                WriteAccess = {write},
                Email = user.Email,
                LastUpdated = DateTime.UtcNow.ToTimestamp(),
                Name = user.FirstName + " " + user.LastName,
                PhoneNumber = user.PhoneNumber ?? string.Empty,
                IsNew = isNew
            };

            Logger.Debug("Adding user update to queue");
            userUpdate.LastUpdated = Timestamp.FromDateTime(DateTime.UtcNow);
            lock (UpdateQueue)
            {
                UpdateQueue.Add(userUpdate);
                RunningSignal.Set();
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    private static UserUpdate? GetNextUserUpdate()
    {
        lock (UpdateQueue)
        {
            if (UpdateQueue.Any())
            {
                var userUpdate = UpdateQueue.First();
                UpdateQueue.RemoveRange(0, 1);
                return userUpdate;
            }

            RunningSignal.Reset();
            return null;
        }
    }

    public static void Initialize()
    {
        StopSignal.Reset();
        var notificationThread = new Thread(UserUpdateHandler);
        notificationThread.Start();
    }

    private static async void UserUpdateHandler(object? o)
    {
        Logger.Info("User update handler started");
        StopSignal.Reset();

        var waitHandles = new WaitHandle[] {RunningSignal, StopSignal};
        while (WaitHandle.WaitAny(waitHandles) == 0)
        {
            var userUpdate = GetNextUserUpdate();
            if (userUpdate == null)
            {
                Thread.Sleep(1000);
                continue;
            }

            Logger.Debug("Sending user update to subscribers");
           await UserServiceServer.Broadcast(userUpdate);
        }
    }
}