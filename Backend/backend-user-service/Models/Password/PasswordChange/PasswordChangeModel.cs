using System.ComponentModel.DataAnnotations;

namespace backend_user_service.Models.Password.PasswordChange;

public class PasswordChangeModel
{
    [Required]
    public string OldPassword { get; set; }
    [Required]
    public string NewPassword { get; set; }
}