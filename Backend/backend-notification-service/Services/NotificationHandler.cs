using System.Text.RegularExpressions;
using backend_notification_service.Models;
using backend_notification_service.NotificationTexts.HTML.Notifications;
using backend_notification_service.NotificationTexts.SMS;
using backend_notification_service.Notifier;
using ssds_notification;

namespace backend_notification_service.Services;

public static class NotificationHandler
{
    public static Task<NotifyAlarmResponse> HandleNormalAlarm(NotifyAlarmRequest request)
    {
        EmailNotificationRequestModel? emailNotification = null;
        SmsNotificationRequestModel? smsNotification = null;
        HttpNotificationRequestModel? httpNotification = null;
        PhoneNotificationRequestModel? phoneNotification = null;

        if (request.AlarmMailNotification != null)
        {
            emailNotification = new EmailNotificationRequestModel()
            {
                Body = NotificationMailHelper.GenerateAlarmMail(request.Location, request.Building,
                    request.BuildingUnit, request.Room, request.SmokeDetectors),
                IsHtml = true,
                Subject = "Feueralarm: " + request.Location,
                Recipient = new RecipientModel()
                {
                    Email = request.AlarmMailNotification.MailAddress
                },
                IsHighPriority = true
            };
        }

        if (request.AlarmSmsNotification != null)
        {
            smsNotification = new SmsNotificationRequestModel()
            {
                Text = SmsTexts.NormalAlarm.Replace("{{location}}", request.Location),
                To = request.AlarmSmsNotification.PhoneNumber
            };
        }

        if (request.AlarmHttpNotification != null)
        {
            httpNotification = new HttpNotificationRequestModel()
            {
                Url = request.AlarmHttpNotification.Url,
                Method = request.AlarmHttpNotification.Method,
                Body = request.AlarmHttpNotification.Body,
                Headers = request.AlarmHttpNotification.Headers
                    .Select(header => new Tuple<string, string>(header.Name, header.Value)).ToList()
            };
        }

        if (request.AlarmPhoneCallNotification != null)
        {
            phoneNotification = new PhoneNotificationRequestModel()
            {
                To = request.AlarmPhoneCallNotification.PhoneNumber
            };
        }

        var notification = new NotificationRequestModel()
        {
            Priority = PriorityType.Critical,
            Email = emailNotification,
            Sms = smsNotification,
            Http = httpNotification,
            Phone = phoneNotification,
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new NotifyAlarmResponse()
            {
                Success = true
            });

        return Task.FromResult(new NotifyAlarmResponse
        {
            Success = false,
            Message = "Failed to add notification to queue"
        });
    }

    public static Task<NotifyAlarmResponse> HandleEvacuationAlarm(NotifyAlarmRequest request)
    {
        EmailNotificationRequestModel? emailNotification = null;
        SmsNotificationRequestModel? smsNotification = null;
        HttpNotificationRequestModel? httpNotification = null;
        PhoneNotificationRequestModel? phoneNotification = null;

        if (request.AlarmMailNotification != null)
        {
            emailNotification = new EmailNotificationRequestModel()
            {
                Body = NotificationMailHelper.GenerateEvacuationAlarmMail(request.Building),
                IsHtml = true,
                Subject = "Evakuierungsalarm: " + request.Location,
                Recipient = new RecipientModel()
                {
                    Email = request.AlarmMailNotification.MailAddress
                },
                IsHighPriority = true
            };
        }

        if (request.AlarmSmsNotification != null)
        {
            smsNotification = new SmsNotificationRequestModel()
            {
                Text = SmsTexts.EvacuationAlarm.Replace("{{building}}", request.Building),
                To = request.AlarmSmsNotification.PhoneNumber
            };
        }

        if (request.AlarmHttpNotification != null)
        {
            httpNotification = new HttpNotificationRequestModel()
            {
                Url = request.AlarmHttpNotification.Url,
                Method = request.AlarmHttpNotification.Method,
                Body = request.AlarmHttpNotification.Body,
                Headers = request.AlarmHttpNotification.Headers
                    .Select(header => new Tuple<string, string>(header.Name, header.Value)).ToList()
            };
        }

        if (request.AlarmPhoneCallNotification != null)
        {
            phoneNotification = new PhoneNotificationRequestModel()
            {
                To = request.AlarmPhoneCallNotification.PhoneNumber
            };
        }

        var notification = new NotificationRequestModel()
        {
            Priority = PriorityType.Critical,
            Email = emailNotification,
            Sms = smsNotification,
            Http = httpNotification,
            Phone = phoneNotification,
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new NotifyAlarmResponse()
            {
                Success = true
            });

        return Task.FromResult(new NotifyAlarmResponse
        {
            Success = false,
            Message = "Failed to add notification to queue"
        });
    }

    public static Task<NotifyAlarmResponse> HandleExpandingAlarm(NotifyAlarmRequest request)
    {
        EmailNotificationRequestModel? emailNotification = null;
        SmsNotificationRequestModel? smsNotification = null;
        HttpNotificationRequestModel? httpNotification = null;
        PhoneNotificationRequestModel? phoneNotification = null;

        if (request.AlarmMailNotification != null)
        {
            emailNotification = new EmailNotificationRequestModel()
            {
                Body = NotificationMailHelper.GenerateExpandingAlarmMail(request.Location, request.Building,
                    request.BuildingUnit, request.Room, request.SmokeDetectors),
                IsHtml = true,
                Subject = "Feuer breitet sich aus: " + request.Location,
                Recipient = new RecipientModel()
                {
                    Email = request.AlarmMailNotification.MailAddress
                },
                IsHighPriority = true
            };
        }

        if (request.AlarmSmsNotification != null)
        {
            smsNotification = new SmsNotificationRequestModel()
            {
                Text = SmsTexts.ExpandingAlarm.Replace("{{location}}", request.Location),
                To = request.AlarmSmsNotification.PhoneNumber
            };
        }

        if (request.AlarmHttpNotification != null)
        {
            httpNotification = new HttpNotificationRequestModel()
            {
                Url = request.AlarmHttpNotification.Url,
                Method = request.AlarmHttpNotification.Method,
                Body = request.AlarmHttpNotification.Body,
                Headers = request.AlarmHttpNotification.Headers
                    .Select(header => new Tuple<string, string>(header.Name, header.Value)).ToList()
            };
        }

        if (request.AlarmPhoneCallNotification != null)
        {
            phoneNotification = new PhoneNotificationRequestModel()
            {
                To = request.AlarmPhoneCallNotification.PhoneNumber
            };
        }

        var notification = new NotificationRequestModel()
        {
            Priority = PriorityType.Critical,
            Email = emailNotification,
            Sms = smsNotification,
            Http = httpNotification,
            Phone = phoneNotification,
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new NotifyAlarmResponse()
            {
                Success = true
            });

        return Task.FromResult(new NotifyAlarmResponse
        {
            Success = false,
            Message = "Failed to add notification to queue"
        });
    }

    public static Task<NotifyAlarmResponse> HandlePreAlarm(NotifyAlarmRequest request)
    {
        EmailNotificationRequestModel? emailNotification = null;
        SmsNotificationRequestModel? smsNotification = null;
        HttpNotificationRequestModel? httpNotification = null;
        PhoneNotificationRequestModel? phoneNotification = null;

        if (request.AlarmMailNotification != null)
        {
            emailNotification = new EmailNotificationRequestModel()
            {
                Body = NotificationMailHelper.GeneratePreAlarmMail(request.Location, request.Building,
                    request.BuildingUnit, request.Room, request.SmokeDetectors),
                IsHtml = true,
                Subject = "Voralarm: " + request.Location,
                Recipient = new RecipientModel()
                {
                    Email = request.AlarmMailNotification.MailAddress
                },
                IsHighPriority = true
            };
        }

        if (request.AlarmSmsNotification != null)
        {
            smsNotification = new SmsNotificationRequestModel()
            {
                Text = SmsTexts.PreAlarm.Replace("{{location}}", request.Location),
                To = request.AlarmSmsNotification.PhoneNumber
            };
        }

        if (request.AlarmHttpNotification != null)
        {
            httpNotification = new HttpNotificationRequestModel()
            {
                Url = request.AlarmHttpNotification.Url,
                Method = request.AlarmHttpNotification.Method,
                Body = request.AlarmHttpNotification.Body,
                Headers = request.AlarmHttpNotification.Headers
                    .Select(header => new Tuple<string, string>(header.Name, header.Value)).ToList()
            };
        }

        if (request.AlarmPhoneCallNotification != null)
        {
            phoneNotification = new PhoneNotificationRequestModel()
            {
                To = request.AlarmPhoneCallNotification.PhoneNumber
            };
        }

        var notification = new NotificationRequestModel()
        {
            Priority = PriorityType.Critical,
            Email = emailNotification,
            Sms = smsNotification,
            Http = httpNotification,
            Phone = phoneNotification,
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new NotifyAlarmResponse()
            {
                Success = true
            });

        return Task.FromResult(new NotifyAlarmResponse
        {
            Success = false,
            Message = "Failed to add notification to queue"
        });
    }

    public static Task<NotifyAlarmResponse> HandleBuildingUnitAutomationAlarm(NotifyAlarmRequest request)
    {
        EmailNotificationRequestModel? emailNotification = null;
        SmsNotificationRequestModel? smsNotification = null;
        HttpNotificationRequestModel? httpNotification = null;
        PhoneNotificationRequestModel? phoneNotification = null;

        if (request.AlarmMailNotification != null)
        {
            var tagRegex = new Regex(@"<\s*([^ >]+)[^>]*>.*?<\s*/\s*\1\s*>");
            var hasTags = tagRegex.IsMatch(request.AlarmMailNotification.Body);


            emailNotification = new EmailNotificationRequestModel()
            {
                Body = request.AlarmMailNotification.Body,
                IsHtml = hasTags,
                Subject = request.AlarmMailNotification.Subject,
                Recipient = new RecipientModel()
                {
                    Email = request.AlarmMailNotification.MailAddress
                },
                IsHighPriority = false
            };
        }

        if (request.AlarmSmsNotification != null)
        {
            smsNotification = new SmsNotificationRequestModel()
            {
                Text = request.AlarmSmsNotification.Text,
                To = request.AlarmSmsNotification.PhoneNumber
            };
        }

        if (request.AlarmHttpNotification != null)
        {
            httpNotification = new HttpNotificationRequestModel()
            {
                Url = request.AlarmHttpNotification.Url,
                Method = request.AlarmHttpNotification.Method,
                Body = request.AlarmHttpNotification.Body,
                Headers = request.AlarmHttpNotification.Headers
                    .Select(header => new Tuple<string, string>(header.Name, header.Value)).ToList()
            };
        }

        if (request.AlarmPhoneCallNotification != null)
        {
            phoneNotification = new PhoneNotificationRequestModel()
            {
                To = request.AlarmPhoneCallNotification.PhoneNumber
            };
        }

        var notification = new NotificationRequestModel()
        {
            Priority = PriorityType.Critical,
            Email = emailNotification,
            Sms = smsNotification,
            Http = httpNotification,
            Phone = phoneNotification,
        };

        if (NotificationManager.AddNotification(notification))
            return Task.FromResult(new NotifyAlarmResponse()
            {
                Success = true
            });

        return Task.FromResult(new NotifyAlarmResponse
        {
            Success = false,
            Message = "Failed to add notification to queue"
        });
    }
}