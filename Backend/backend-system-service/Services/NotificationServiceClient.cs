using backend_system_service.Helper;
using NLog;
using Grpc.Core;
using Grpc.Net.Client;
using ssds_mail_notifications;
using ssds_notification;

namespace backend_system_service.Services;

public static class NotificationServiceClient
{
    private static Thread? _thread;
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private const string UserServiceUrl = "http://localhost:85";

    public static bool SendNotification(NotificationType type, NotifyAlarmRequest notification)
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

            var client = new NotificationService.NotificationServiceClient(channel);

            var res = type switch
            {
                NotificationType.NormalAlarm => client.NotifyNormalAlarm(notification, GetHeaders()),
                NotificationType.EvacuationAlarm => client.NotifyEvacuationAlarm(notification, GetHeaders()),
                NotificationType.ExpandingAlarm => client.NotifyExpandingAlarm(notification, GetHeaders()),
                NotificationType.PreAlarm => client.NotifyPreAlarm(notification, GetHeaders()),
                NotificationType.BuildingUnitAutomationAlarm => client.NotifyBuildingUnitAutomationAlarm(notification,
                    GetHeaders()),
                _ => throw new ArgumentOutOfRangeException(nameof(type), type, null)
            };

            if (res is { Success: true }) return true;

            Logger.Error($"Error while sending notification: {res.Message}");
            return false;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    public static bool SendGwOff5Minutes(string gatewayName, Guid buildingUnit, Guid tenantId)
    {
        try
        {
            var users = PermissionHelper.GetWriteUsersInBuildingUnit(buildingUnit, tenantId);

            var channel = GrpcChannel.ForAddress(UserServiceUrl, new GrpcChannelOptions());
            var client = new MailNotificationService.MailNotificationServiceClient(channel);

            foreach (var user in users)
            {
                var res = client.SendGatewayOffline5Minutes(new GatewayRequest()
                {
                    Email = user.Email,
                    GatewayName = gatewayName,
                    Name = user.Name
                }, GetHeaders());

                if (!res.Success)
                {
                    Logger.Error($"Error while sending notification to {user.Email}! - {res.ErrorMessage}");
                }
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    public static bool SendGwOff15Minutes(string gatewayName, Guid buildingUnit, Guid tenantId)
    {
        try
        {
            var users = PermissionHelper.GetWriteUsersInBuildingUnit(buildingUnit, tenantId);

            var channel = GrpcChannel.ForAddress(UserServiceUrl, new GrpcChannelOptions());
            var client = new MailNotificationService.MailNotificationServiceClient(channel);

            foreach (var user in users)
            {
                var res = client.SendGatewayOffline15Minutes(new GatewayRequest()
                {
                    Email = user.Email,
                    GatewayName = gatewayName,
                    Name = user.Name
                }, GetHeaders());

                if (!res.Success)
                {
                    Logger.Error($"Error while sending notification to {user.Email}! - {res.ErrorMessage}");
                }
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    public static bool SendGwBackOnline(string gatewayName, Guid buildingUnit, Guid tenantId)
    {
        try
        {
            var users = PermissionHelper.GetWriteUsersInBuildingUnit(buildingUnit, tenantId);

            var channel = GrpcChannel.ForAddress(UserServiceUrl, new GrpcChannelOptions());
            var client = new MailNotificationService.MailNotificationServiceClient(channel);

            foreach (var user in users)
            {
                var res = client.SendGatewayBackOnline(new GatewayRequest()
                {
                    Email = user.Email,
                    GatewayName = gatewayName,
                    Name = user.Name
                }, GetHeaders());

                if (!res.Success)
                {
                    Logger.Error($"Error while sending notification to {user.Email}! - {res.ErrorMessage}");
                }
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    public static bool SendBatteryReplace(string sdName, Guid buildingUnit, Guid tenantId)
    {
        try
        {
            var users = PermissionHelper.GetWriteUsersInBuildingUnit(buildingUnit, tenantId);

            var channel = GrpcChannel.ForAddress(UserServiceUrl, new GrpcChannelOptions());
            var client = new MailNotificationService.MailNotificationServiceClient(channel);

            foreach (var user in users)
            {
                var res = client.SendBatteryReplacementNeeded(new SmokeMaintenanceRequest()
                {
                    Email = user.Email,
                    SmokeName = sdName,
                    Name = user.Name
                }, GetHeaders());

                if (!res.Success)
                {
                    Logger.Error($"Error while sending notification to {user.Email}! - {res.ErrorMessage}");
                }
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    public static bool SendMaintenance7Days(string sdName, Guid buildingUnit, Guid tenantId)
    {
        try
        {
            var users = PermissionHelper.GetWriteUsersInBuildingUnit(buildingUnit, tenantId);

            var channel = GrpcChannel.ForAddress(UserServiceUrl, new GrpcChannelOptions());
            var client = new MailNotificationService.MailNotificationServiceClient(channel);

            foreach (var user in users)
            {
                var res = client.SendMaintenanceNeeded(new SmokeMaintenanceRequest()
                {
                    Email = user.Email,
                    SmokeName = sdName,
                    Name = user.Name
                }, GetHeaders());

                if (!res.Success)
                {
                    Logger.Error($"Error while sending notification to {user.Email}! - {res.ErrorMessage}");
                }
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }


    private static Metadata GetHeaders()
    {
        var metadata = new Metadata();
        if (Program.JwtSettings == null) throw new Exception("JWT settings not found");
        var key = Program.JwtSettings.BackendValidationKey;
        metadata.Add("x-custom-backend-auth", key);
        return metadata;
    }
}

public enum NotificationType
{
    NormalAlarm,
    EvacuationAlarm,
    ExpandingAlarm,
    PreAlarm,
    BuildingUnitAutomationAlarm
}