using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Identity;

namespace Core.Entities;

public class AppUser : IdentityUser
{
    [Required] public string FirstName { get; set; } = null!;
    [Required] public string LastName { get; set; } = null!;
    public bool HasConfirmedMail { get; set; }
    [Required] public bool IsSuperAdmin { get; set; }
    [Required] public bool IsTenantAdmin { get; set; }
    [Required] public Guid TenantId { get; set; }
    public List<string> ReadAccess { get; set; } = new();
    public List<string> WriteAccess { get; set; } = new();
    [JsonIgnore] public string? RefreshToken { get; set; }
    [JsonIgnore] public DateTime? RefreshTokenExpiration { get; set; }
    [JsonIgnore] public Guid? ResetPasswordToken { get; set; }
    [JsonIgnore] public DateTime? ResetPasswordTokenExpiration { get; set; }
    [JsonIgnore] public Guid? MailConfirmationToken { get; set; }
    [JsonIgnore] public DateTime? MailConfirmationTokenExpiration { get; set; }

    #region ignoredStandardProperties

    [JsonIgnore] public override string? PasswordHash { get; set; }

    [JsonIgnore] public override string? SecurityStamp { get; set; }

    [JsonIgnore] public override string? ConcurrencyStamp { get; set; }

    [JsonIgnore] public override string? NormalizedEmail { get; set; }

    [JsonIgnore] public override string? NormalizedUserName { get; set; }

    [JsonIgnore] public override bool TwoFactorEnabled { get; set; }

    [JsonIgnore] public override bool EmailConfirmed { get; set; }

    [JsonIgnore] public override bool LockoutEnabled { get; set; }

    [JsonIgnore] public override int AccessFailedCount { get; set; }

    [JsonIgnore] public override DateTimeOffset? LockoutEnd { get; set; }

    [JsonIgnore] public override bool PhoneNumberConfirmed { get; set; }

    [JsonIgnore] public override string? PhoneNumber { get; set; }

    #endregion
    
    
}