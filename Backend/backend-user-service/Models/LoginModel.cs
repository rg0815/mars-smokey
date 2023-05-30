using System.ComponentModel.DataAnnotations;

namespace backend_user_service.Models;

public class LoginModel
{
    [Required] public string Mail { get; set; }
    [Required] public string Password { get; set; }

}