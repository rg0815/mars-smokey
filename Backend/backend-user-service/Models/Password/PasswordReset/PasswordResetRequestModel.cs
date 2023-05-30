using System.ComponentModel.DataAnnotations;

namespace backend_user_service.Models.Password.PasswordReset;

public class PasswordResetRequestModel
{
    [Required] public string Email { get; set; }
    [Required] public string Url { get; set; }
    [Required] public string Name { get; set; }
}