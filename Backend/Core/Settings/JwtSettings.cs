namespace Core.Settings;

public class JwtSettings
{
    public string Key { get; set; } = null!;
    public string Issuer { get; set; } = null!;
    public string Audience { get; set; } = null!;
    public string Subject { get; set; } = null!;
    public double TokenValidityInMinutes { get; set; }
    public double RefreshTokenValidityInDays { get; set; }
    public string BackendValidationKey { get; set; } = null!;
}