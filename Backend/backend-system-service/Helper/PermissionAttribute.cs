using System.Security.Claims;
using Core.Helper;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace backend_system_service.Helper;

public class PermissionAttribute : TypeFilterAttribute
{
    public PermissionAttribute(PermissionType role) : base(typeof(PermissionFilter))
    {
        Arguments = new object[]
        {
            role,
        };
    }
}

public class PermissionFilter : IAuthorizationFilter
{
    private readonly PermissionType _role;

    public PermissionFilter(PermissionType role)
    {
        _role = role;
    }

    public async void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;
        if (user.Identity == null) context.Result = new UnauthorizedResult();
        else
        {
            if (!user.Identity.IsAuthenticated)
            {
                context.Result = new UnauthorizedResult();
            }
            else
            {
                var userId = user.Claims.FirstOrDefault(c => c.Type == "Id")?.Value;
                if (userId == null)
                {
                    context.Result = new UnauthorizedResult();
                }
                else
                {
                    var roleModel = PermissionHelper.GetRole(userId);
                    if (roleModel == null)
                    {
                        context.Result = new UnauthorizedResult();
                    }
                    else
                    {
                        switch (_role)
                        {
                            case PermissionType.SuperAdmin when !roleModel.IsSuperAdmin:
                            case PermissionType.TenantAdmin when !roleModel.IsTenantAdmin:
                                context.Result = new ForbidResult();
                                break;
                            case PermissionType.SuperAdminOrTenantAdmin:
                            {
                                if (roleModel is {IsSuperAdmin: false, IsTenantAdmin: false})
                                    context.Result = new ForbidResult();
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}