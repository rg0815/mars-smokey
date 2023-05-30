namespace Core.Entities;

public class Header : BaseEntity
{
    public Guid HttpNotificationId { get; set; }
    public HttpNotification HttpNotification { get; set; }
    public string? Key { get; set; }
    public string? Value { get; set; }
}