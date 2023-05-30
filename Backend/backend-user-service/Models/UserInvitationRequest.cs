namespace backend_user_service.Models;

public class UserInvitationRequest
{
    public string Email { get; set; } = null!;
    public List<string> ReadAccess { get; set; } = new();
    public List<string> WriteAccess { get; set; } = new();
    public bool IsTenantAdmin { get; set; }
}