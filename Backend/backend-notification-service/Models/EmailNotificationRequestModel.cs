namespace backend_notification_service.Models;

public class EmailNotificationRequestModel
{
    public RecipientModel Recipient { get; set; }
    public string Subject { get; set; }
    public string Body { get; set; }
    public bool IsHtml { get; set; }
    public bool IsHighPriority { get; set; }
}

public class RecipientModel
{
    public string Email { get; set; }
    public string Name { get; set; }
}