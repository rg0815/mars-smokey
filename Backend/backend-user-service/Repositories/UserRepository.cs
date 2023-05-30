using System.Security.Claims;
using backend_user_service.Service;
using Core.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace backend_user_service.Repositories;

public class UserRepository
{
    private readonly UserManager<AppUser> _userManager;
    private readonly ILogger<UserRepository> _logger;

    public UserRepository(ILogger<UserRepository> logger, UserManager<AppUser> userManager)
    {
        _logger = logger;
        _userManager = userManager;
    }

    public async Task<AppUser?> FindByEmailAsync(string email)
    {
        var res = await _userManager.FindByEmailAsync(email);
        return res;
    }

    public async Task<AppUser?> FindByIdAsync(string id)
    {
        var res = await _userManager.FindByIdAsync(id);
        return res;
    }

    public async Task<IdentityResult> CreateAsync(AppUser user, string password)
    {
        var res = await _userManager.CreateAsync(user, password);
        UserUpdateManager.AddUserUpdate(user, true);
        return res;
    }

    public async Task<IdentityResult> UpdateAsync(AppUser user)
    {
        var res = await _userManager.UpdateAsync(user);
        UserUpdateManager.AddUserUpdate(user, false);
        return res;
    }

    public async Task<IdentityResult> AddReadPermissions(AppUser user, IEnumerable<string> readPermissions)
    {
        var existingPermissions = user.ReadAccess;
        var newPermissions = readPermissions.Where(p => !existingPermissions.Contains(p)).ToList();
        user.ReadAccess.AddRange(newPermissions);
        var res = await _userManager.UpdateAsync(user);
        UserUpdateManager.AddUserUpdate(user, false);
        return res;
    }

    public async Task<IdentityResult> AddWritePermissions(AppUser user, IEnumerable<string> writePermissions)
    {
        var existingPermissions = user.WriteAccess;
        var newPermissions = writePermissions.Where(p => !existingPermissions.Contains(p)).ToList();
        user.WriteAccess.AddRange(newPermissions);
        var res = await _userManager.UpdateAsync(user);
        UserUpdateManager.AddUserUpdate(user, false);
        return res;
    }

    public async Task<IdentityResult> RemoveReadPermissions(AppUser user, IEnumerable<string> readPermissions)
    {
        var existingPermissions = user.ReadAccess;
        var newPermissions = readPermissions.Where(p => existingPermissions.Contains(p)).ToList();
        user.ReadAccess.RemoveAll(p => newPermissions.Contains(p));
        var res = await _userManager.UpdateAsync(user);
        UserUpdateManager.AddUserUpdate(user, false);
        return res;
    }

    public async Task<IdentityResult> RemoveWritePermissions(AppUser user, IEnumerable<string> writePermissions)
    {
        var existingPermissions = user.WriteAccess;
        var newPermissions = writePermissions.Where(p => existingPermissions.Contains(p)).ToList();
        user.WriteAccess.RemoveAll(p => newPermissions.Contains(p));
        var res = await _userManager.UpdateAsync(user);
        UserUpdateManager.AddUserUpdate(user, false);
        return res;
    }

    public async Task<IdentityResult> DeleteAsync(AppUser user)
    {
        // TODO: handle user deletion (userupdates)
        return await _userManager.DeleteAsync(user);
    }

    public async Task<IdentityResult> ChangePasswordAsync(AppUser user, string currentPassword, string newPassword)
    {
        return await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);
    }

    public async Task<IdentityResult> ResetPasswordAsync(AppUser user, string token, string newPassword)
    {
        return await _userManager.ResetPasswordAsync(user, token, newPassword);
    }

    public async Task<string> GeneratePasswordResetTokenAsync(AppUser user)
    {
        return await _userManager.GeneratePasswordResetTokenAsync(user);
    }

    public async Task<string> GenerateEmailConfirmationTokenAsync(AppUser user)
    {
        return await _userManager.GenerateEmailConfirmationTokenAsync(user);
    }

    public async Task<IdentityResult> ConfirmEmailAsync(AppUser user, string token)
    {
        return await _userManager.ConfirmEmailAsync(user, token);
    }

    public async Task<bool> IsEmailConfirmedAsync(AppUser user)
    {
        return await _userManager.IsEmailConfirmedAsync(user);
    }

    public List<AppUser> GetUsers()
    {
        return _userManager.Users.ToList();
    }

    public async Task<List<AppUser>> GetTenantUsers(Guid tenantId)
    {
        return await _userManager.Users.Where(u => u.TenantId == tenantId).ToListAsync();
    }

    public async Task<List<AppUser>> GetTenantAdmins(Guid tenantId)
    {
        return await _userManager.Users.Where(u => u.TenantId == tenantId && u.IsTenantAdmin)
            .ToListAsync();
    }

    public async Task<List<AppUser>> GetSuperAdmins()
    {
        return await _userManager.Users.Where(u => u.IsSuperAdmin).ToListAsync();
    }

    public async Task<bool> CheckPasswordAsync(AppUser user, string requestPassword)
    {
        return await _userManager.CheckPasswordAsync(user, requestPassword);
    }

    public async Task<IdentityResult> AddPasswordAsync(AppUser user, string password)
    {
        return await _userManager.AddPasswordAsync(user, password);
    }

    public async Task<IdentityResult> RemovePasswordAsync(AppUser user)
    {
        return await _userManager.RemovePasswordAsync(user);
    }

    public async Task<IEnumerable<Claim>> GetClaimsAsync(AppUser user)
    {
        return await _userManager.GetClaimsAsync(user);
    }
}