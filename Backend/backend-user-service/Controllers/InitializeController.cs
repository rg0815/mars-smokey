using backend_user_service.Logging;
using backend_user_service.Models;
using backend_user_service.Repositories;
using backend_user_service.Repository;
using Core.Entities;
using Core.Helper;
using Microsoft.AspNetCore.Mvc;

namespace backend_user_service.Controllers;

[ApiController]
[Route("/api/user/initialize")]
public class InitializeController : ControllerBase
{
    private readonly UserRepository _userRepository;
    private readonly ILogger<InitializeController> _logger;

    public InitializeController(ILogger<InitializeController> logger, UserRepository userRepository)
    {
        _logger = logger;
        _userRepository = userRepository;
    }

    [HttpGet]
    public ActionResult IsInitialized()
    {
        try
        {
            if (!_userRepository.GetUsers().Any())
            {
                _logger.LogInformation("Application is not initialized!");
                return Ok("Application is not initialized!");
            }

            _logger.LogInformation(LogEvents.DatabaseAlreadyInit, LogMessages.DatabaseAlreadyInit);
            return Ok("Application is initialized!");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails(LogMessages.UnknownError, ErrorCode.Unknown));
        }
    }

    [HttpPost]
    public async Task<ActionResult> Setup(FirstTenantRegistrationModel user)
    {
        try
        {
            if (_userRepository.GetUsers().Any())
            {
                _logger.LogInformation("Application is initialized!");
                return BadRequest("Application is initialized!");
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(new ErrorDetails("Invalid model", ErrorCode.InvalidModelState));
            }

            if (user is not { Password: { }, Email: { } })
                return BadRequest(new ErrorDetails("Bad credentials", ErrorCode.InvalidCredentials));

            if (_userRepository.FindByEmailAsync(user.Email).Result != null)
                return Conflict(new ErrorDetails("User already exists", ErrorCode.UserAlreadyExists));

            var result = await _userRepository.CreateAsync(
                new AppUser
                {
                    UserName = user.Email, Email = user.Email, FirstName = user.FirstName, LastName = user.LastName,
                    RefreshToken = "", RefreshTokenExpiration = DateTime.MinValue, HasConfirmedMail = true,
                    IsSuperAdmin = true, TenantId = user.TenantId, IsTenantAdmin = true
                },
                user.Password
            );

            if (!result.Succeeded)
            {
                return BadRequest(new ErrorDetails("User creation failed! Please check user details and try again.",
                    ErrorCode.UserCreationFailed));
            }

            var identUser = _userRepository.FindByEmailAsync(user.Email).Result;
            if (identUser == null) return NotFound("User not found");

            user.Password = "";
            return Ok(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails("Unknown error", ErrorCode.Unknown));
        }
    }
}