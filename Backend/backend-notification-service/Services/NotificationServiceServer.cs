using Grpc.Core;
using ssds_notification;

namespace backend_notification_service.Services;

public class NotificationServiceServer : NotificationService.NotificationServiceBase
{
    private readonly ILogger<NotificationServiceServer> _logger;

    public NotificationServiceServer(ILogger<NotificationServiceServer> logger)
    {
        _logger = logger;
    }

    public override Task<NotifyAlarmResponse> NotifyNormalAlarm(NotifyAlarmRequest request, ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        return NotificationHandler.HandleNormalAlarm(request);
    }

    public override Task<NotifyAlarmResponse> NotifyEvacuationAlarm(NotifyAlarmRequest request,
        ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        return NotificationHandler.HandleEvacuationAlarm(request);
    }

    public override Task<NotifyAlarmResponse> NotifyExpandingAlarm(NotifyAlarmRequest request,
        ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        return NotificationHandler.HandleExpandingAlarm(request);
    }

    public override Task<NotifyAlarmResponse> NotifyPreAlarm(NotifyAlarmRequest request, ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        return NotificationHandler.HandlePreAlarm(request);
    }

    public override Task<NotifyAlarmResponse> NotifyBuildingUnitAutomationAlarm(NotifyAlarmRequest request,
        ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new NotifyAlarmResponse
            {
                Success = false,
                Message = "No authorization header"
            });
        }

        return NotificationHandler.HandleBuildingUnitAutomationAlarm(request);
    }
}