using backend_notification_service.Models;
using backend_notification_service.NotificationTexts.HTML.UserMail;
using backend_notification_service.Notifier;
using Grpc.Core;
using ssds_mail_notifications;

namespace backend_notification_service.Services;

public class MailServiceServer : MailNotificationService.MailNotificationServiceBase
{
    private readonly ILogger<MailServiceServer> _logger;

    public MailServiceServer(ILogger<MailServiceServer> logger)
    {
        _logger = logger;
    }

    public override Task<BasicResponse> SendInvitationExistingUser(InvitationExistingUserRequest request,
        ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        var notification = new NotificationRequestModel
        {
            Email = new EmailNotificationRequestModel
            {
                Body = UserMailHelper.GenerateInvitationExistingAccount(request.Name),
                IsHtml = true,
                Subject = "Neue Berechtigung in Ihrem Account",
                Recipient = new RecipientModel()
                {
                    Email = request.Email,
                    Name = request.Name
                },
                IsHighPriority = false
            }
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new BasicResponse()
            {
                Success = true
            });

        return Task.FromResult(new BasicResponse
        {
            Success = false,
            ErrorMessage = "Failed to add notification to queue"
        });
    }

    public override Task<BasicResponse> SendInvitationNewUser(InvitationNewUserRequest request,
        ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        var notification = new NotificationRequestModel
        {
            Email = new EmailNotificationRequestModel
            {
                Body = UserMailHelper.GenerateInvitationNewAccount(request.ActionUrl, request.Email),
                IsHtml = true,
                Subject = "Einladung zum Beitritt zu mars smokey",
                Recipient = new RecipientModel
                {
                    Email = request.Email,
                },
                IsHighPriority = false
            }
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new BasicResponse
            {
                Success = true
            });

        return Task.FromResult(new BasicResponse
        {
            Success = false,
            ErrorMessage = "Failed to add notification to queue"
        });
    }

    public override Task<BasicResponse> SendAccountConfirmation(AccountConfirmationRequest request,
        ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        var notification = new NotificationRequestModel
        {
            Email = new EmailNotificationRequestModel
            {
                Body = UserMailHelper.GenerateAccountConfirmation(request.Name, request.ActionUrl, request.Email),
                IsHtml = true,
                Subject = "Bestätigung Ihres Accounts",
                Recipient = new RecipientModel()
                {
                    Email = request.Email,
                    Name = request.Name
                },
                IsHighPriority = false
            }
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new BasicResponse
            {
                Success = true
            });

        return Task.FromResult(new BasicResponse
        {
            Success = false,
            ErrorMessage = "Failed to add notification to queue"
        });
    }

    public override Task<BasicResponse> SendPasswordChange(PasswordChangeRequest request, ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        var notification = new NotificationRequestModel
        {
            Email = new EmailNotificationRequestModel
            {
                Body = UserMailHelper.GeneratePasswordChanged(request.Name),
                IsHtml = true,
                Subject = "Passwort geändert",
                Recipient = new RecipientModel()
                {
                    Email = request.Email,
                    Name = request.Name
                },
                IsHighPriority = false
            }
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new BasicResponse
            {
                Success = true
            });

        return Task.FromResult(new BasicResponse
        {
            Success = false,
            ErrorMessage = "Failed to add notification to queue"
        });
    }

    public override Task<BasicResponse> SendPasswordReset(PasswordResetRequest request, ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(h => h.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Success = false,
                ErrorMessage = "No authorization header"
            });
        }

        var notification = new NotificationRequestModel
        {
            Email = new EmailNotificationRequestModel
            {
                Body = UserMailHelper.GeneratePasswordReset(request.Name, request.ActionUrl),
                IsHtml = true,
                Subject = "Passwort zurücksetzen",
                Recipient = new RecipientModel()
                {
                    Email = request.Email,
                    Name = request.Name
                },
                IsHighPriority = false
            }
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new BasicResponse
            {
                Success = true
            });

        return Task.FromResult(new BasicResponse
        {
            Success = false,
            ErrorMessage = "Failed to add notification to queue"
        });
    }
}