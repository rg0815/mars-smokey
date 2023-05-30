using System.Security.Claims;
using backend_user_service.Helper;
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
[Route("/api/user/invitation/")]
public class InvitationController : ControllerBase
{
    private readonly UserRepository _userRepository;
    private readonly IUserInvitationRepository _userInvitationRepository;
    private readonly ILogger<InvitationController> _logger;

    public InvitationController(UserRepository userRepository, IUserInvitationRepository userInvitationRepository, ILogger<InvitationController> logger)
    {
        _userRepository = userRepository;
        _userInvitationRepository = userInvitationRepository;
        _logger = logger;
    }

    [HttpPost("{tenantId?}")]
    [Permission(PermissionType.SuperAdminOrTenantAdmin)]
    public async Task<ActionResult> CreateInvitation([FromBody] UserInvitationRequest invitation, string tenantId)
    {
        var mail = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
        if (mail == null) return BadRequest();
        var loggedInUser = await _userRepository.FindByEmailAsync(mail);
        if (loggedInUser == null) return BadRequest(new ErrorDetails("User not found", ErrorCode.UserNotFound));

        var usedTenantId = loggedInUser.IsSuperAdmin ? new Guid(tenantId) : loggedInUser.TenantId;
        
        var existingUser = await _userRepository.FindByEmailAsync(invitation.Email);
        var userExists = existingUser != null;

        var invitationEntity = new UserInvitation
        {
            Email = invitation.Email,
            ReadAccess = invitation.ReadAccess,
            WriteAccess = invitation.WriteAccess,
            ExpirationDate = DateTime.Now.AddDays(7).ToUniversalTime(),
            RegistrationToken = Guid.NewGuid(),
            IsAccepted = userExists,
            IsDeleted = false,
            InvitedBy = loggedInUser.Email!,
            TenantId = usedTenantId,
            IsTenantAdmin = invitation.IsTenantAdmin,
        };

        if (userExists) invitationEntity.AcceptedDate = DateTime.Now.ToUniversalTime();
        _userInvitationRepository.Insert(invitationEntity);

        bool result;
        switch (userExists)
        {
            case false:
                var model = new InvitationNewUserRequest()
                {
                    ActionUrl = EndpointsHelper.GetInvitationUrl(invitationEntity.RegistrationToken),
                    Email = invitation.Email,
                };

                result = NotificationService.SendInvitationNewUser(model);
                break;
            case true:

                if (!(await _userRepository.AddReadPermissions(existingUser!, invitation.ReadAccess)).Succeeded)
                    return BadRequest(new ErrorDetails("Could not add read permissions", ErrorCode.Unknown));
                if (!(await _userRepository.AddWritePermissions(existingUser!, invitation.WriteAccess)).Succeeded)
                    return BadRequest(new ErrorDetails("Could not add write permissions", ErrorCode.Unknown));

                var exModel = new InvitationExistingUserRequest()
                {
                    Email = invitation.Email,
                    Name = $"{existingUser!.FirstName} {existingUser.LastName}",
                };

                result = NotificationService.SendInvitationExistingUser(exModel);
                break;
        }

        if (!result) return BadRequest(new ErrorDetails("Could not send invitation", ErrorCode.Unknown));
        return Ok();
    }
    
    [HttpGet]
    [Route("{token}")]
    public ActionResult<UserInvitation> GetInvitationByToken(string token)
    {
        if (string.IsNullOrWhiteSpace(token)) return BadRequest(new ErrorDetails("Token is empty", ErrorCode.InvalidToken));
        if (!Guid.TryParse(token, out var tokenGuid)) return BadRequest(new ErrorDetails("Token is not valid", ErrorCode.InvalidToken));

        var invitation = _userInvitationRepository.GetByCondition(i => i.RegistrationToken == tokenGuid);
        if (invitation == null) return BadRequest(new ErrorDetails("Invitation not found", ErrorCode.InvitationNotFound));
        if (invitation.IsAccepted) return BadRequest(new ErrorDetails("Invitation is already accepted", ErrorCode.InvitationAlreadyAccepted));
        if (invitation.ExpirationDate < DateTime.Now) return BadRequest(new ErrorDetails("Invitation is expired", ErrorCode.InvitationExpired));
        if (invitation.IsDeleted) return BadRequest(new ErrorDetails("Invitation is deleted", ErrorCode.InvitationDeleted));

        return Ok(invitation);
    }

    [HttpGet]
    [Authorize, Permission(PermissionType.TenantAdmin)]
    public ActionResult<List<UserInvitation>> GetInvitations()
    {
        var mail = User.FindFirstValue(ClaimTypes.Email);
        if (mail == null) return BadRequest(new ErrorDetails("User not found", ErrorCode.UserNotFound));
        var user = _userRepository.FindByEmailAsync(mail).Result;
        if (user == null) return BadRequest(new ErrorDetails("User not found", ErrorCode.UserNotFound));

        var invitations = _userInvitationRepository.GetAll();
        return Ok(invitations);
    }
}