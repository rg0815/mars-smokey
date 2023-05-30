using System.Security.Claims;
using backend_user_service.Helper;
using backend_user_service.Logging;
using backend_user_service.Models;
using backend_user_service.Models.Token;
using backend_user_service.Repositories;
using backend_user_service.Repository;
using backend_user_service.Service;
using Core.Helper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend_user_service.Controllers;

[ApiController]
[Route("/api/user/auth")]
public class AuthController : ControllerBase
{
    private readonly UserRepository _userRepository;
    private readonly TokenService _tokenService;
    private readonly ILogger<AuthController> _logger;


    public AuthController(TokenService tokenService,
        ILogger<AuthController> logger, UserRepository userRepository)
    {
        _tokenService = tokenService;
        _logger = logger;
        _userRepository = userRepository;
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AuthResponse>> Login(LoginModel request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                _logger.LogInformation(LogEvents.ModelStateInvalid, LogMessages.NoInformation);
                return BadRequest(new ErrorDetails("Model state is invalid", ErrorCode.InvalidModelState));
            }

            var user = await _userRepository.FindByEmailAsync(request.Mail);
            if (user == null)
            {
                return Unauthorized(new ErrorDetails("Bad credentials", ErrorCode.InvalidCredentials));
            }

            var isPasswordValid = await _userRepository.CheckPasswordAsync(user, request.Password);

            if (!isPasswordValid)
            {
                _logger.LogInformation(LogEvents.CredentialsNotMatching,
                    LogMessages.CredentialsNotMatching.Replace("[MAIL]", request.Mail));
                return  Unauthorized(new ErrorDetails("Bad credentials", ErrorCode.InvalidCredentials));
            }

            if(!user.HasConfirmedMail)
                return Unauthorized(new ErrorDetails("Mail not confirmed", ErrorCode.MailNotConfirmed));
            
            var token = await _tokenService.CreateToken(user);
            if (token == null) return BadRequest(new ErrorDetails("Internal Error", ErrorCode.InternalError));
            
            token.AppUser = user;
            return Ok(token);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails(LogMessages.UnknownError, ErrorCode.Unknown));
        }
    }

    [HttpPost("refresh")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AuthResponse>> RefreshToken(TokenModel request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                _logger.LogInformation(LogEvents.ModelStateInvalid, LogMessages.NoInformation);
                return BadRequest(new ErrorDetails("Model state is invalid", ErrorCode.InvalidModelState));
            }

            var principal = _tokenService.GetPrincipalFromExpiredToken(request.AccessToken);
            var mail = principal.Claims.FirstOrDefault(x => x.Type == ClaimTypes.Email)?.Value;
            if(mail == null) return Unauthorized(new ErrorDetails("Bad credentials", ErrorCode.InvalidEmail ));
            var user = await _userRepository.FindByEmailAsync(mail);
            if(user == null) return Unauthorized(new ErrorDetails("Bad credentials", ErrorCode.InvalidEmail ));
            if(user.RefreshToken != request.RefreshToken) return Unauthorized(new ErrorDetails("Bad credentials", ErrorCode.InvalidRefreshToken ));
            if(user.RefreshTokenExpiration <= DateTime.UtcNow) return Unauthorized(new ErrorDetails("Bad credentials", ErrorCode.RefreshTokenExpired ));
            if(!user.HasConfirmedMail) return Unauthorized(new ErrorDetails("Bad credentials", ErrorCode.MailNotConfirmed ));

            var token = await _tokenService.CreateToken(user);
            if (token == null) return BadRequest(new ErrorDetails("Internal Error", ErrorCode.InternalError));
            
            token.AppUser = user;
            return Ok(token);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails(LogMessages.UnknownError, ErrorCode.Unknown));
        }
    }
    
    
    [Permission(PermissionType.SuperAdmin)]
    [HttpPost]
    [Route("revoke/{mail}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Revoke(string mail)
    {
        var user = await _userRepository.FindByEmailAsync(mail);
        if (user == null) return BadRequest(new ErrorDetails("User not found", ErrorCode.UserNotFound));

        user.RefreshToken = null;
        await _userRepository.UpdateAsync(user);

        return NoContent();
    }

    [Authorize]
    [Permission(PermissionType.SuperAdmin)]
    [HttpPost]
    [Route("revoke-all")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RevokeAll()
    {
        var users = _userRepository.GetUsers();
        foreach (var user in users)
        {
            user.RefreshToken = null;
            await _userRepository.UpdateAsync(user);
        }

        return NoContent();
    }
}