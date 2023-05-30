using backend_user_service.Helper;
using backend_user_service.Logging;
using backend_user_service.Models.Password.PasswordChange;
using backend_user_service.Models.Password.PasswordReset;
using backend_user_service.Repositories;
using backend_user_service.Repository;
using backend_user_service.Service;
using Core.Helper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ssds_mail_notifications;

namespace backend_user_service.Controllers;

[ApiController]
[Route("/api/user/password/")]
public class PasswordController : ControllerBase
{
    private readonly UserRepository _userRepository;
    private readonly ILogger<PasswordController> _logger;

    public PasswordController(UserRepository userRepository, ILogger<PasswordController> logger)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    /// <summary>
    /// Change a user's password.
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    [HttpPut("change"), Authorize]
    public async Task<IActionResult> ChangePassword(PasswordChangeModel model)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ErrorDetails("Invalid model", ErrorCode.InvalidModelState));
            }

            if (User.Identity?.Name == null) return BadRequest(new ErrorDetails("Invalid mail", ErrorCode.InvalidEmail));

            var user = await _userRepository.FindByEmailAsync(User.Identity.Name);
            if (user == null)
            {
                return NotFound(new ErrorDetails("User not found", ErrorCode.UserNotFound));
            }

            var result =
                await _userRepository.ChangePasswordAsync(user, model.OldPassword, model.NewPassword);
            if (!result.Succeeded) return BadRequest(new ErrorDetails("Failed to change password", ErrorCode.FailedToChangePassword));

            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails(LogMessages.UnknownError, ErrorCode.Unknown));
        }
    }

    /// <summary>
    /// Send a password reset email.
    /// </summary>
    /// <param name="requestModel"></param>
    /// <returns></returns>
    [HttpPost("request-reset")]
    public async Task<IActionResult> ResetPassword(PasswordResetRequestModel requestModel)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ErrorDetails("Invalid model", ErrorCode.InvalidModelState));
            }

            var user = await _userRepository.FindByEmailAsync(requestModel.Email);
            if (user == null)
            {
                //return ok in order to not leak information about users
                return Ok();
            }

            var token = Guid.NewGuid();
            user.ResetPasswordToken = token;
            user.ResetPasswordTokenExpiration = DateTime.Now.AddHours(1).ToUniversalTime();
            var result = await _userRepository.UpdateAsync(user);
            if (!result.Succeeded) return BadRequest(new ErrorDetails("Failed to update user", ErrorCode.FailedToUpdateUser));
            if (user.Email == null) return BadRequest( new ErrorDetails("Failed to update user", ErrorCode.FailedToUpdateUser));

            var model = new PasswordResetRequest()
            {
                ActionUrl = EndpointsHelper.GetResetPasswordUrl(token),
                Name = user.FirstName + " " + user.LastName,
                Email = requestModel.Email
            };
            var res = NotificationService.SendPasswordReset(model);
            if (!res) return BadRequest(new ErrorDetails("Failed to send email", ErrorCode.FailedToSendMail));
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, LogMessages.UnknownError);
            return BadRequest(new ErrorDetails(LogMessages.UnknownError, ErrorCode.Unknown));
        }
    }

    /// <summary>
    /// Change a user's password using a reset token.
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    [HttpPost("reset")]
    public async Task<IActionResult> ChangePasswordReset(ChangePasswordResetModel model)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new ErrorDetails("Invalid model", ErrorCode.InvalidModelState));
        }

        var user = await _userRepository.FindByEmailAsync(model.Email);
        if (user == null)
        {
            return NotFound(new ErrorDetails("User not found", ErrorCode.UserNotFound));
        }

        if (user.ResetPasswordToken != model.Token) return BadRequest(new ErrorDetails("Invalid token", ErrorCode.InvalidToken));
        if (user.ResetPasswordTokenExpiration < DateTime.Now.ToUniversalTime()) return BadRequest(new ErrorDetails("Token expired", ErrorCode.TokenExpired));

        user.ResetPasswordToken = null;
        user.ResetPasswordTokenExpiration = DateTime.MinValue.ToUniversalTime();
        var res = await _userRepository.UpdateAsync(user);
        if (!res.Succeeded) return BadRequest(new ErrorDetails("Failed to change password", ErrorCode.FailedToChangePassword));

        var result = await _userRepository.RemovePasswordAsync(user);
        if (!result.Succeeded) return BadRequest(new ErrorDetails("Failed to change password", ErrorCode.FailedToChangePassword));

        var identityResult = await _userRepository.AddPasswordAsync(user, model.NewPassword);
        if (!identityResult.Succeeded)
            return BadRequest(new ErrorDetails("Failed to change password", ErrorCode.FailedToChangePassword));

        var notiResult = NotificationService.SendPasswordChanged(new PasswordChangeRequest()
        {
            Email = model.Email,
            Name = user.FirstName + " " + user.LastName
        });
        if (!notiResult) return BadRequest(new ErrorDetails("Failed to send email", ErrorCode.FailedToSendMail));

        return Ok();
    }
}