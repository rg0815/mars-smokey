namespace backend_notification_service.Settings;

public class NotifierSettings
{
    public MailSettings Mail { get; set; }
    public HttpSettings Http { get; set; }
    public SmsSettings Sms { get; set; }
    public PhoneCallSettings PhoneCall { get; set; }
}

public class MailSettings
{
    public bool Enabled { get; set; }
    public string Host { get; set; }
    public int Port { get; set; }
    public string MailAddress { get; set; }
    public string Password { get; set; }
    public string FromName { get; set; }
    public bool AuthNeeded { get; set; }
}

public class HttpSettings
{
    public bool Enabled { get; set; }
}

public class SmsSettings
{
    public bool Enabled { get; set; }
    public bool Debug { get; set; }
    public string ApiKey { get; set; }
    public string From { get; set; }
}

public class PhoneCallSettings
{
    public bool Enabled { get; set; }
    public string PathToPhoneCallTool { get; set; }
}