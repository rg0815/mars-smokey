using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;


namespace backend_system_service.Services;

public static class TokenService
{
    public static string CreateToken()
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.UTF8.GetBytes(Program.JwtSettings.Key);
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Issuer = Program.JwtSettings.Issuer,
            Audience = Program.JwtSettings.Audience,
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.Name, Program.JwtSettings.Subject),
            }),
            Expires = DateTime.UtcNow.AddMinutes(Program.JwtSettings.TokenValidityInMinutes),
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature)
        };
        
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
    


    public static Tuple<string, string> ValidateToken(string token)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.UTF8.GetBytes(Program.JwtSettings.Key);
        tokenHandler.ValidateToken(token, new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(key),
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidIssuer = Program.JwtSettings.Issuer,
            ValidAudience = Program.JwtSettings.Audience,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero,
        }, out var validatedToken);
        
        var jwtToken = (JwtSecurityToken) validatedToken;
        var id = jwtToken.Claims.FirstOrDefault(x => x.Type == "Id")?.Value;
        var email = jwtToken.Claims.FirstOrDefault(x => x.Type == "email")?.Value;
        return new Tuple<string, string>(id ?? string.Empty, email ?? string.Empty);
    }
}