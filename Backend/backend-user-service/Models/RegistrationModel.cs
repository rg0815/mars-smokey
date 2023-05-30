using System.ComponentModel.DataAnnotations;

namespace backend_user_service.Models;

public class RegistrationModel
{
    [Required] public string FirstName { get; set; }
    [Required] public string LastName { get; set; }
    [Required] public string Email { get; set; }
    [Required] public string Password { get; set; }
}

public class FirstTenantRegistrationModel : RegistrationModel
{
    [Required] public Guid TenantId { get; set; }
}