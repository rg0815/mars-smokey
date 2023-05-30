using backend_system_service.Models;
using backend_system_service.Repositories;
using Core.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend_system_service.Controllers
{
    [Route("api/[controller]")]
    [ApiController, Authorize]
    public class NotificationSettingController : BaseController
    {
        private readonly IGenericRepository<NotificationSetting> _notificationSettingRepository;

        public NotificationSettingController(IGenericRepository<NotificationSetting> notificationSettingRepository)
        {
            _notificationSettingRepository = notificationSettingRepository;
        }

        [HttpGet("{userId:guid}")]
        public ActionResult<NotificationSetting> GetNotificationSettingsByUserId(Guid userId)
        {
            if (Roles == null) return Forbid();
            if (Roles.UserId != userId) return Forbid();

            var notificationSetting = _notificationSettingRepository.GetByCondition(x => x.UserId == userId);
            if (notificationSetting != null) return Ok(notificationSetting);

            if (Roles.UserId != userId) return Forbid();
            notificationSetting = new NotificationSetting()
            {
                EmailNotification = true,
                PhoneCallNotification = false,
                PushNotification = false,
                SmsNotification = false,
                HttpNotification = false,
                UserId = userId,
                Email = new UserEmailNotification
                {
                    Email = Roles.Email,
                },
                HttpNotifications = new List<HttpNotification>(),
                PushNotificationTokens = new List<PushNotificationToken>(),
                PhoneNumber = new PhoneCallNotification()
                {
                    PhoneNumber = ""
                },
                SmsNumber = new SmsNotification()
                {
                    PhoneNumber = ""
                }
            };

            _notificationSettingRepository.Insert(notificationSetting);
            return Ok(notificationSetting);
        }

        [HttpPost, Route("{userId:guid}")]
        public ActionResult<NotificationSetting> UpdateNotificationSettingsByUserId(
            AddOrUpdateNotificationRequest notificationSettings, Guid userId)
        {
            if (Roles == null) return Forbid();
            if (Roles.UserId != userId) return Forbid();
            
            var settings = _notificationSettingRepository.GetByCondition(x => x.UserId == userId);
            if (settings == null)
            {
                return BadRequest("No notification settings found for this user");
            }

            settings.PhoneCallNotification = notificationSettings.PhoneCallNotification;
            settings.SmsNotification = notificationSettings.SmsNotification;
            settings.PushNotification = notificationSettings.PushNotification;
            settings.EmailNotification = notificationSettings.EmailNotification;
            settings.HttpNotification = notificationSettings.HttpNotification;

            settings.PhoneNumber.PhoneNumber = notificationSettings.PhoneNumber;
            settings.SmsNumber.PhoneNumber = notificationSettings.NumbersAreIdentical
                ? notificationSettings.PhoneNumber
                : notificationSettings.SMSNumber;

            settings.Email.Email = notificationSettings.Email ?? Roles.Email;
            settings.HttpNotifications = notificationSettings.HttpNotifications.Select(x => new HttpNotification()
            {
                Body = x.Body,
                Headers = (x.Headers ?? new List<AddHeaderRequest>()).Select(y => new Header()
                {
                    Key = y.Key,
                    Value = y.Value
                }).ToList(),
                Method = x.Method,
                Url = x.Url
            }).ToList();

            _notificationSettingRepository.Update(settings);
            return Ok(settings);
        }

        [HttpPost, Route("push/{userId:guid}")]
        public ActionResult AddPushDevice(Guid userId, string deviceToken)
        {
            if (Roles == null) return Forbid();
            if (Roles.UserId != userId) return Forbid();

            var setting = _notificationSettingRepository.GetByCondition(x => x.UserId == userId);
            if (setting == null) return NotFound();

            var tokens = setting.PushNotificationTokens;
            if (tokens.Any(x => x.Token == deviceToken)) return Ok();

            setting.PushNotificationTokens.Add(new PushNotificationToken()
            {
                Token = deviceToken
            });
            _notificationSettingRepository.Update(setting);
            return Ok();
        }

        [HttpPut, Route("push/{userId:guid}")]
        public ActionResult UpdatePushDevice(Guid userId, string oldToken, string newToken)
        {
            if (Roles == null) return Forbid();
            if (Roles.UserId != userId) return Forbid();

            var setting = _notificationSettingRepository.GetByCondition(x => x.UserId == userId);
            if (setting == null) return NotFound();

            if (setting.PushNotificationTokens.FirstOrDefault(x => x.Token == oldToken) == null)
            {
                return NotFound();
            }

            var old = setting.PushNotificationTokens.FirstOrDefault(x => x.Token == oldToken);
            if (old != null) setting.PushNotificationTokens.Remove(old);
            setting.PushNotificationTokens.Add(new PushNotificationToken()
            {
                Token = newToken
            });
            _notificationSettingRepository.Update(setting);
            return Ok();
        }
    }
}