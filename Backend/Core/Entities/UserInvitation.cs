namespace Core.Entities;

public class UserInvitation
{
    public Guid Id { get; set; }
    public Guid RegistrationToken { get; set; }
    public string InvitedBy { get; set; } = null!;
    public string Email { get; set; } = null!;
    public bool IsTenantAdmin { get; set; }
    public List<string> ReadAccess { get; set; } = new();
    public List<string> WriteAccess { get; set; } = new();
    public bool IsAccepted { get; set; }
    public DateTime ExpirationDate { get; set; }
    public DateTime? AcceptedDate { get; set; }
    public bool IsDeleted { get; set; }
    public Guid TenantId { get; set; }
}