using System.ComponentModel.DataAnnotations;

namespace backend_user_service.Models.Password.PasswordReset;

public class ChangePasswordResetModel
{
    [Required] public string Email { get; set; }
    [Required] public Guid Token { get; set; }
    [Required] public string NewPassword { get; set; }
}