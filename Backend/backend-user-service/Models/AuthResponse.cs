using Core.Entities;

namespace backend_user_service.Models;

public class AuthResponse
{
    public string? AccessToken { get; set; }
    public string? RefreshToken { get; set; }
    public DateTime? AccessTokenExpiration { get; set; }
    public DateTime? RefreshTokenExpiration { get; set; }
    public AppUser AppUser { get; set; }
}