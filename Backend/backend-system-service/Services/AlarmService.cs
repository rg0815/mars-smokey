using backend_system_service.Database;
using backend_system_service.Helper;
using backend_system_service.Models;
using backend_system_service.MQTT;
using backend_system_service.Repositories;
using Core.Entities;
using Google.Protobuf.Collections;
using Microsoft.EntityFrameworkCore;
using NLog;
using ssds_notification;
using Header = ssds_notification.Header;

namespace backend_system_service.Services;

public static class AlarmService
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static void HandleAlarm(AlarmHandlerModel alarm)
    {
        var options = new DbContextOptions<DatabaseContext>();
        var notificationRepository = new GenericRepository<NotificationSetting>(new DatabaseContext(options));
        var automationSettingRepository = new GenericRepository<AutomationSetting>(new DatabaseContext(options));

        Logger.Info("Handling alarm for: " + alarm.BuildingUnit.Name);

        #region UserNotifications

        if (alarm.IsExpanding)
            Logger.Info("Alarm is expanding");

        if (alarm.IsProbableFalseAlarm)
            Logger.Info("Alarm is probable false alarm");

        if (alarm is {HandlePreAlarm: true, IsProbableFalseAlarm: true})
        {
            var preAlarmNotification = alarm.BuildingUnit.PreAlarmNotification;
            HandlePreAlarm(preAlarmNotification, alarm);
        }
        else
        {
            var usersInBuildingUnit =
                PermissionHelper.GetUsersInBuildingUnit(alarm.BuildingUnit.Id, alarm.BuildingUnit.Building.TenantId);

            var usersInBuilding = new List<Guid>();
            foreach (var buildingUnit in alarm.BuildingUnit.Building.BuildingUnits)
            {
                usersInBuildingUnit.AddRange(PermissionHelper.GetUsersInBuildingUnit(buildingUnit.Id,
                    alarm.BuildingUnit.Building.TenantId));
            }

            if (alarm.IsExpanding)
            {
                foreach (var notifcations in usersInBuildingUnit.Select(userId =>
                             notificationRepository.GetAllByCondition(x => x.UserId == userId)))
                {
                    HandleExpanding(notifcations, alarm);
                }
            }
            else
            {
                if (alarm.EvacuateBuilding)
                {
                    foreach (var notifcations in usersInBuilding.Select(userId =>
                                 notificationRepository.GetAllByCondition(x => x.UserId == userId)))
                    {
                        HandleEvacuate(notifcations, alarm);
                    }
                }

                else
                {
                    var notificationSettings = new List<NotificationSetting>();
                    foreach (var userId in usersInBuildingUnit)
                    {
                        notificationSettings.AddRange(
                            notificationRepository.GetAllByCondition(x => x.UserId == userId));
                    }

                    HandleNormalAlarm(notificationSettings, alarm);
                }
            }
        }

        #endregion

        #region AutomationSettings

        if (alarm is {IsExpanding: false, IsProbableFalseAlarm: false})
        {
            var automationSettings = automationSettingRepository.GetAllByCondition(x =>
                x.BuildingUnitId == alarm.BuildingUnit.Id);

            HandleAutomationSettings(automationSettings, alarm);
        }

        if (!alarm.BuildingUnit.SendMqttInfo) return;

        var mqttText = alarm.BuildingUnit.MqttText ?? "";
        mqttText = mqttText.Replace("{{location}}", alarm.Location);
        mqttText = mqttText.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
        mqttText = mqttText.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
        mqttText = mqttText.Replace("{{room}}", alarm.Room.Name);
        mqttText = mqttText.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
        mqttText = mqttText.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
        mqttText = mqttText.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
        MqttClient.SendAlarmInformation(alarm.BuildingUnit.Id, mqttText);

        #endregion
    }

    private static void HandleNormalAlarm(List<NotificationSetting> notifications, AlarmHandlerModel alarmHandlerModel)
    {
        foreach (var notificationSetting in notifications)
        {
            SendAlarm(NotificationType.NormalAlarm, notificationSetting, alarmHandlerModel);
        }
    }

    private static void HandleEvacuate(IEnumerable<NotificationSetting> notifications,
        AlarmHandlerModel alarmHandlerModel)
    {
        foreach (var notificationSetting in notifications)
        {
            SendAlarm(NotificationType.EvacuationAlarm, notificationSetting, alarmHandlerModel);
        }
    }

    private static void HandleExpanding(IEnumerable<NotificationSetting> notifications,
        AlarmHandlerModel alarmHandlerModel)
    {
        foreach (var notificationSetting in notifications)
        {
            SendAlarm(NotificationType.ExpandingAlarm, notificationSetting, alarmHandlerModel);
        }
    }

    private static void HandlePreAlarm(PreAlarmAutomationSetting notification, AlarmHandlerModel alarmHandlerModel)
    {
        SendAlarm(NotificationType.PreAlarm, notification, alarmHandlerModel);
    }

    private static void SendAlarm(NotificationType type, NotificationSetting setting,
        AlarmHandlerModel alarmHandlerModel)
    {
        var request = new NotifyAlarmRequest
        {
            BuildingUnit = alarmHandlerModel.BuildingUnit.Name,
            Building = alarmHandlerModel.BuildingUnit.Building.Name,
            Location = alarmHandlerModel.Location,
            Room = alarmHandlerModel.Room.Name,
            SmokeDetectors = {alarmHandlerModel.SmokeDetectors},
        };

        if (setting.EmailNotification)
        {
            request.AlarmMailNotification = new AlarmMailNotification()
            {
                MailAddress = setting.Email.Email
            };
        }

        if (setting.PhoneCallNotification)
        {
            request.AlarmPhoneCallNotification = new AlarmPhoneCallNotification()
            {
                PhoneNumber = setting.PhoneNumber.PhoneNumber
            };
        }

        if (setting.SmsNotification)
        {
            request.AlarmSmsNotification = new AlarmSmsNotification()
            {
                PhoneNumber = setting.PhoneNumber.PhoneNumber,
            };
        }

        var res = NotificationServiceClient.SendNotification(type, request);
        if (!res)
        {
            Logger.Error("Error while sending notification");
        }

        HandlePushNotification(setting);
    }

    private static void HandlePushNotification(NotificationSetting setting)
    {
//TODO
    }

    private static void SendAlarm(NotificationType type, PreAlarmAutomationSetting setting, AlarmHandlerModel alarm)
    {
        NotifyAlarmRequest request;
        foreach (var mail in setting.EmailNotifications)
        {
            var text = mail.Text ?? "";
            if (alarm != null)
            {
                text = text.Replace("{{location}}", alarm.Location);
                text = text.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                text = text.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                text = text.Replace("{{room}}", alarm.Room.Name);
                text = text.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                text = text.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                text = text.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            var subject = mail.Subject ?? "";
            if (alarm != null)
            {
                subject = subject.Replace("{{location}}", alarm.Location);
                subject = subject.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                subject = subject.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                subject = subject.Replace("{{room}}", alarm.Room.Name);
                subject = subject.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                subject = subject.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                subject = subject.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }


            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmMailNotification = new AlarmMailNotification()
                {
                    MailAddress = mail.Email,
                    Body = text,
                    Subject = subject
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }

        foreach (var sms in setting.SmsNotifications)
        {
            var text = sms.Text ?? "";
            if (alarm != null)
            {
                text = text.Replace("{{location}}", alarm.Location);
                text = text.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                text = text.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                text = text.Replace("{{room}}", alarm.Room.Name);
                text = text.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                text = text.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                text = text.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmSmsNotification = new AlarmSmsNotification()
                {
                    PhoneNumber = sms.PhoneNumber,
                    Text = text
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }

        foreach (var phoneCall in setting.PhoneCallNotifications)
        {
            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmPhoneCallNotification = new AlarmPhoneCallNotification()
                {
                    PhoneNumber = phoneCall.PhoneNumber
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }

        foreach (var http in setting.HttpNotifications)
        {
            //http.headers to repeatedField
            var headers = new RepeatedField<Header>();
            if (http.Headers != null)
                foreach (var header in http.Headers)
                {
                    headers.Add(new Header()
                    {
                        Name = header.Key,
                        Value = header.Value
                    });
                }

            var text = http.Body ?? "";
            if (alarm != null)
            {
                text = text.Replace("{{location}}", alarm.Location);
                text = text.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                text = text.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                text = text.Replace("{{room}}", alarm.Room.Name);
                text = text.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                text = text.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                text = text.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            var url = http.Url ?? "";
            if (alarm != null)
            {
                url = url.Replace("{{location}}", alarm.Location);
                url = url.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                url = url.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                url = url.Replace("{{room}}", alarm.Room.Name);
                url = url.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                url = url.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                url = url.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmHttpNotification = new AlarmHttpNotification()
                {
                    Url = url,
                    Body = text,
                    Method = http.Method,
                    Headers = {headers}
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }
    }
    
     private static void SendAlarm(NotificationType type, AutomationSetting setting, AlarmHandlerModel alarm)
    {
        NotifyAlarmRequest request;
        foreach (var mail in setting.EmailNotifications)
        {
            var text = mail.Text ?? "";
            if (alarm != null)
            {
                text = text.Replace("{{location}}", alarm.Location);
                text = text.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                text = text.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                text = text.Replace("{{room}}", alarm.Room.Name);
                text = text.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                text = text.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                text = text.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            var subject = mail.Subject ?? "";
            if (alarm != null)
            {
                subject = subject.Replace("{{location}}", alarm.Location);
                subject = subject.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                subject = subject.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                subject = subject.Replace("{{room}}", alarm.Room.Name);
                subject = subject.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                subject = subject.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                subject = subject.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }


            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmMailNotification = new AlarmMailNotification()
                {
                    MailAddress = mail.Email,
                    Body = text,
                    Subject = subject
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }

        foreach (var sms in setting.SmsNotifications)
        {
            var text = sms.Text ?? "";
            if (alarm != null)
            {
                text = text.Replace("{{location}}", alarm.Location);
                text = text.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                text = text.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                text = text.Replace("{{room}}", alarm.Room.Name);
                text = text.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                text = text.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                text = text.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmSmsNotification = new AlarmSmsNotification()
                {
                    PhoneNumber = sms.PhoneNumber,
                    Text = text
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }

        foreach (var phoneCall in setting.PhoneCallNotifications)
        {
            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmPhoneCallNotification = new AlarmPhoneCallNotification()
                {
                    PhoneNumber = phoneCall.PhoneNumber
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }

        foreach (var http in setting.HttpNotifications)
        {
            //http.headers to repeatedField
            var headers = new RepeatedField<Header>();
            if (http.Headers != null)
                foreach (var header in http.Headers)
                {
                    headers.Add(new Header()
                    {
                        Name = header.Key,
                        Value = header.Value
                    });
                }

            var text = http.Body ?? "";
            if (alarm != null)
            {
                text = text.Replace("{{location}}", alarm.Location);
                text = text.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                text = text.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                text = text.Replace("{{room}}", alarm.Room.Name);
                text = text.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                text = text.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                text = text.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            var url = http.Url ?? "";
            if (alarm != null)
            {
                url = url.Replace("{{location}}", alarm.Location);
                url = url.Replace("{{building}}", alarm.BuildingUnit.Building.Name);
                url = url.Replace("{{buildingUnit}}", alarm.BuildingUnit.Name);
                url = url.Replace("{{room}}", alarm.Room.Name);
                url = url.Replace("{{isExpanding}}", alarm.IsExpanding.ToString());
                url = url.Replace("{{isProbableFalseAlarm}}", alarm.IsProbableFalseAlarm.ToString());
                url = url.Replace("{{isEvacuation}}", alarm.EvacuateBuilding.ToString());
            }

            request = new NotifyAlarmRequest
            {
                BuildingUnit = alarm.BuildingUnit.Name,
                Building = alarm.BuildingUnit.Building.Name,
                Location = alarm.Location,
                Room = alarm.Room.Name,
                SmokeDetectors = {alarm.SmokeDetectors},
                AlarmHttpNotification = new AlarmHttpNotification()
                {
                    Url = url,
                    Body = text,
                    Method = http.Method,
                    Headers = {headers}
                }
            };
            NotificationServiceClient.SendNotification(type, request);
        }
    }

    private static void HandleAutomationSettings(IEnumerable<AutomationSetting> automationSettings,
        AlarmHandlerModel? alarm = null)
    {
        foreach (var setting in automationSettings)
        {
            SendAlarm(NotificationType.BuildingUnitAutomationAlarm, setting, alarm);
        }
    }
}