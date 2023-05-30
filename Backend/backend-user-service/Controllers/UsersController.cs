using System.Security.Claims;
using backend_user_service.Helper;
using backend_user_service.Logging;
using backend_user_service.Models;
using backend_user_service.Repositories;
using backend_user_service.Repository;
using backend_user_service.Service;
using Core.Entities;
using Core.Helper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ssds_mail_notifications;

namespace backend_user_service.Controllers;

[ApiController]
[Route("/api/user/")]
public class UsersController : ControllerBase
{
    private readonly UserRepository _userRepository;
    private readonly IUserInvitationRepository _userInvitationRepository;
    private readonly ILogger<UsersController> _logger;

    public UsersController(ILogger<UsersController> logger,
        IUserInvitationRepository userInvitationRepository, UserRepository userRepository)
    {
        _logger = logger;
        _userInvitationRepository = userInvitationRepository;
        _userRepository = userRepository;
    }

    /// <summary>
    /// Create a user, which was invited.
    /// It is not necessary to confirm the email address.
    /// </summary>
    /// <param name="user"></param>
    /// <param name="registrationToken"></param>
    /// <returns></returns>
    [HttpPost]
    [Route("register/{registrationToken}")]
    public async Task<ActionResult<AppUser>> RegisterNewUserFromInvitation([FromBody] RegistrationModel user,
        string registrationToken)
    {
        if (string.IsNullOrEmpty(registrationToken))
            return BadRequest(new ErrorDetails("Invalid Token", ErrorCode.InvalidToken));
        if (!Guid.TryParse(registrationToken, out var tokenGuid))
            return BadRequest(new ErrorDetails("Invalid Token", ErrorCode.InvalidToken));

        var invitation = _userInvitationRepository.GetByCondition(i => i.RegistrationToken == tokenGuid);
        if (invitation == null) return BadRequest(new ErrorDetails("Invalid Token", ErrorCode.InvalidToken));
        if (invitation.IsAccepted)
            return BadRequest(new ErrorDetails("Invitation is already accepted", ErrorCode.InvitationAlreadyAccepted));
        if (invitation.ExpirationDate < DateTime.Now)
            return BadRequest(new ErrorDetails("Invitation is expired", ErrorCode.InvitationExpired));
        if (invitation.IsDeleted)
            return BadRequest(new ErrorDetails("Invitation is deleted", ErrorCode.InvitationDeleted));
        if (invitation.Email != user.Email) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));

        if (!ModelState.IsValid)
        {
            return BadRequest(new ErrorDetails("Invalid Model", ErrorCode.InvalidModelState));
        }

        if (user is not { Password: { }, Email: { } })
            return BadRequest(new ErrorDetails("Invalid credentials", ErrorCode.InvalidCredentials));

        if (_userRepository.FindByEmailAsync(user.Email).Result != null)
            return Conflict(new ErrorDetails("User already exists", ErrorCode.UserAlreadyExists));

        var result = await _userRepository.CreateAsync(
            new AppUser
            {
                UserName = user.Email, Email = user.Email, FirstName = user.FirstName, LastName = user.LastName,
                RefreshToken = "", RefreshTokenExpiration = DateTime.MinValue, HasConfirmedMail = true,
                ReadAccess = invitation.ReadAccess, WriteAccess = invitation.WriteAccess, IsTenantAdmin = false,
                IsSuperAdmin = false, TenantId = invitation.TenantId
            },
            user.Password
        );

        if (!result.Succeeded)
        {
            return BadRequest(new ErrorDetails("Failed to create user", ErrorCode.FailedToCreateUser));
        }

        invitation.IsAccepted = true;
        _userInvitationRepository.Update(invitation);

        return new ObjectResult(user) { StatusCode = StatusCodes.Status201Created };
    }

    /// <summary>
    /// Create a new tenant admin. This is only possible by the web app.
    /// The User needs to confirm his mail address.
    /// </summary>
    /// <param name="user"></param>
    /// <param name="tenantId"></param>
    /// <returns></returns>
    [HttpPost]
    [Route("register/tenant-admin/{tenantId}")]
    public async Task<ActionResult<AppUser>> CreateTenantAdmin([FromBody] RegistrationModel user, string tenantId)
    {
        if (string.IsNullOrEmpty(tenantId))
            return BadRequest(new ErrorDetails("Invalid TenantId", ErrorCode.InvalidTenantId));
        if (!Guid.TryParse(tenantId, out var tenantGuid))
            return BadRequest(new ErrorDetails("Invalid TenantId", ErrorCode.InvalidTenantId));

        if (!ModelState.IsValid)
        {
            return BadRequest(new ErrorDetails("Invalid Model", ErrorCode.InvalidModelState));
        }

        if (user is not { Password: { }, Email: { } })
            return BadRequest(new ErrorDetails("Invalid credentials", ErrorCode.InvalidCredentials));

        if (_userRepository.FindByEmailAsync(user.Email).Result != null)
            return Conflict(new ErrorDetails("User already exists", ErrorCode.UserAlreadyExists));

        var result = await _userRepository.CreateAsync(
            new AppUser
            {
                UserName = user.Email, Email = user.Email, FirstName = user.FirstName, LastName = user.LastName,
                RefreshToken = "", RefreshTokenExpiration = DateTime.MinValue, IsTenantAdmin = true,
                IsSuperAdmin = false, TenantId = tenantGuid
            },
            user.Password
        );

        if (!result.Succeeded)
        {
            return BadRequest(new ErrorDetails("Failed to create user", ErrorCode.FailedToCreateUser));
        }

        var identUser = _userRepository.FindByEmailAsync(user.Email).Result;
        if (identUser == null) return NotFound(new ErrorDetails("Internal error", ErrorCode.InternalError));

        var token = Guid.NewGuid();
        identUser.MailConfirmationToken = token;
        identUser.MailConfirmationTokenExpiration = DateTime.Now.AddDays(7).ToUniversalTime();
        var uResult = await _userRepository.UpdateAsync(identUser);
        if (!uResult.Succeeded)
            return BadRequest(new ErrorDetails("Failed to create user", ErrorCode.FailedToCreateUser));

        var requestModel = new AccountConfirmationRequest()
        {
            ActionUrl = EndpointsHelper.GetConfirmAccountUrl(token),
            Name = user.FirstName + " " + user.LastName,
            Email = user.Email
        };

        var notificationResult = NotificationService.SendAccountConfirmation(requestModel);
        if (!notificationResult) return BadRequest(new ErrorDetails("Failed to send mail", ErrorCode.FailedToSendMail));

        return new ObjectResult(identUser) { StatusCode = StatusCodes.Status201Created };
    }


    /// <summary>
    /// Gets the current user.
    /// </summary>
    /// <returns></returns>
    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<AppUser>> GetMe()
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ErrorDetails("Invalid Model", ErrorCode.InvalidModelState));
            }


            var mail = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
            if (mail == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));


            var user = await _userRepository.FindByEmailAsync(mail);
            if (user == null)
            {
                return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));
            }

            return Ok(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails("Unknown Error", ErrorCode.Unknown));
        }
    }


    /// <summary>
    /// Get all tenant admins for a tenant.
    /// </summary>
    /// <param name="tenantId"></param>
    /// <returns></returns>
    [HttpGet]
    [Authorize, Permission(PermissionType.SuperAdminOrTenantAdmin)]
    [Route("tenant-admin/{tenantId}")]
    public async Task<ActionResult<List<AppUser>>> GetTenantAdmins(string tenantId)
    {
        try
        {
            if (string.IsNullOrEmpty(tenantId))
                return BadRequest(new ErrorDetails("Invalid TenantId", ErrorCode.InvalidTenantId));
            if (!Guid.TryParse(tenantId, out var tenantGuid))
                return BadRequest(new ErrorDetails("Invalid TenantId", ErrorCode.InvalidTenantId));

            var mail = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
            if (mail == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));

            var currentUser = await _userRepository.FindByEmailAsync(mail);
            if (currentUser == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));

            if (currentUser is { IsTenantAdmin: false, IsSuperAdmin: false }) return Forbid();

            var tenantAdmins = await _userRepository.GetTenantAdmins(tenantGuid);
            return Ok(!tenantAdmins.Any() ? new List<AppUser>() : tenantAdmins);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails("Unknown Error", ErrorCode.Unknown));
        }
    }

    /// <summary>
    /// Get all users.
    /// </summary>
    /// <returns></returns>
    [HttpGet]
    [Route("tenant-users/{tenantId}")]
    [Permission(PermissionType.SuperAdminOrTenantAdmin)]
    public async Task<ActionResult<List<AppUser>>> GetAllTenantUsers(string tenantId)
    {
        try
        {
            if (!Guid.TryParse(tenantId, out var tenantGuid))
                return BadRequest(new ErrorDetails("Invalid TenantId", ErrorCode.InvalidTenantId));

            var users = await _userRepository.GetTenantUsers(tenantGuid);
            return Ok(users);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails("Unknown Error", ErrorCode.Unknown));
        }
    }

    /// <summary>
    /// Get a user by email.
    /// </summary>
    /// <param name="mail"></param>
    /// <returns></returns>
    [HttpGet("{mail}"), Authorize]
    public async Task<ActionResult<AppUser>> GetUser(string mail)
    {
        try
        {
            var currentMail = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
            if (currentMail == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));
            var currentUser = await _userRepository.FindByEmailAsync(currentMail);
            if (currentUser == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));

            var searchedUser = await _userRepository.FindByEmailAsync(mail);
            if (searchedUser == null) return NotFound(new ErrorDetails("User not found", ErrorCode.UserNotFound));

            if (currentUser is { IsSuperAdmin: true }) return Ok(searchedUser);
            if (currentUser is { IsTenantAdmin: true } && searchedUser.TenantId == currentUser.TenantId)
                return Ok(searchedUser);
            if (currentUser.Email == searchedUser.Email) return Ok(searchedUser);

            return Forbid();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails("Unknown Error", ErrorCode.Unknown));
        }
    }


    /// <summary>
    /// Update a user.
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    [HttpPut, Authorize]
    public async Task<ActionResult<AppUser>> UpdateUser(RegistrationModel model)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ErrorDetails("Invalid Model", ErrorCode.InvalidModelState));
            }

            var currentMail = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
            if (currentMail == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));
            var currentUser = await _userRepository.FindByEmailAsync(currentMail);
            if (currentUser == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));

            var toUpdateUser = await _userRepository.FindByEmailAsync(model.Email);
            if (toUpdateUser == null) return BadRequest(new ErrorDetails("Invalid Mail", ErrorCode.InvalidEmail));

            if (currentUser is { IsSuperAdmin: false, IsTenantAdmin: false })
            {
                if (currentUser.Email != toUpdateUser.Email) return Forbid();
            }
            else if (currentUser is { IsTenantAdmin: true })
            {
                if (toUpdateUser.TenantId != currentUser.TenantId) return Forbid();
            }

            toUpdateUser.FirstName = model.FirstName;
            toUpdateUser.LastName = model.LastName;

            var result = await _userRepository.UpdateAsync(toUpdateUser);

            if (!result.Succeeded) return BadRequest(new ErrorDetails("Internal Error", ErrorCode.InternalError));

            model.Password = "";
            return Ok(model);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails("Unknown Error", ErrorCode.Unknown));
        }
    }
}