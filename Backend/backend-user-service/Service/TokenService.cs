using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using backend_user_service.Models;
using backend_user_service.Repositories;
using backend_user_service.Repository;
using Core.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;

namespace backend_user_service.Service;

public class TokenService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<TokenService> _logger;
    private readonly UserRepository _userRepository;

    public TokenService(IConfiguration configuration, UserRepository userRepository,
        ILogger<TokenService> logger)
    {
        _configuration = configuration;
        _userRepository = userRepository;
        _logger = logger;
    }

    public async Task<AuthResponse?> CreateToken(AppUser user)
    {
        var expiration = DateTime.UtcNow.AddMinutes(Convert.ToDouble(_configuration["Jwt:TokenValidityInMinutes"]));
        var claims = await CreateClaims(user);

        var token = CreateJwtToken(claims, CreateSigningCredentials(), expiration);
        var refreshToken = GenerateRefreshToken();

        user.RefreshToken = refreshToken;
        var days = Convert.ToDouble(_configuration["Jwt:RefreshTokenValidityInDays"]);
        user.RefreshTokenExpiration = DateTime.UtcNow.AddDays(days);

        var res = await _userRepository.UpdateAsync(user);
        if (!res.Succeeded)
        {
            return null;
        }

        var tokenHandler = new JwtSecurityTokenHandler();

        return new AuthResponse
        {
            AccessToken = tokenHandler.WriteToken(token),
            AccessTokenExpiration = expiration,
            RefreshToken = refreshToken,
            RefreshTokenExpiration = user.RefreshTokenExpiration,
            AppUser = user
        };
    }

    private static string GenerateRefreshToken()
    {
        var randomNumber = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        return Convert.ToBase64String(randomNumber);
    }

    private JwtSecurityToken CreateJwtToken(List<Claim> claims, SigningCredentials credentials,
        DateTime expiration) =>
        new(
            _configuration["Jwt:Issuer"],
            _configuration["Jwt:Audience"],
            claims,
            expires: expiration,
            signingCredentials: credentials
        );

    private async Task<List<Claim>> CreateClaims(AppUser user)
    {
        try
        {
            if (user.UserName == null || user.Email == null) return new List<Claim>();

            var options = new IdentityOptions();

            var claims = new List<Claim>
            {
                new("Id", user.Id),
                new(JwtRegisteredClaimNames.Email, user.Email),
                new(JwtRegisteredClaimNames.Sub, user.Email),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new(options.ClaimsIdentity.UserIdClaimType, user.Id),
                new(options.ClaimsIdentity.EmailClaimType, user.Email),
            };

            // var userClaims = await _userRepository.GetClaimsAsync(user);
            // claims.AddRange(userClaims);
            // var userRoles = await _userManager.GetRolesAsync(user);
            // foreach (var userRole in userRoles)
            // {
            //     claims.Add(new Claim(ClaimTypes.Role, userRole));
            //     var role = Role_LogHelper.FindByNameAsync(_logger, _roleManager, userRole);
            //     if (role == null) continue;
            //
            //     var roleClaims = await Role_LogHelper.GetClaimsAsync(_logger, _roleManager, role);
            //     claims.AddRange(roleClaims);
            // }

            return claims;
        }
        catch (Exception e)
        {
            _logger.LogError(e, "Error");
            return new List<Claim>();
        }
    }

    private SigningCredentials CreateSigningCredentials()
    {
        return new SigningCredentials(
            new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? string.Empty)
            ),
            SecurityAlgorithms.HmacSha256
        );
    }

    public ClaimsPrincipal GetPrincipalFromExpiredToken(string? token)
    {
        var tokenValidationParameters = new TokenValidationParameters
        {
            ValidateAudience = false,
            ValidateIssuer = false,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? string.Empty)),
            ValidateLifetime = false
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out var securityToken);
        if (securityToken is not JwtSecurityToken jwtSecurityToken ||
            !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256,
                StringComparison.InvariantCultureIgnoreCase))
            throw new SecurityTokenException("Invalid token");

        return principal;
    }
}