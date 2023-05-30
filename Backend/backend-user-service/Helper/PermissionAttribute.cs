using System.Security.Claims;
using backend_user_service.Repositories;
using backend_user_service.Repository;
using Core.Helper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace backend_user_service.Helper;

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
                var repo = context.HttpContext.RequestServices.GetService(typeof(UserRepository)) as UserRepository;
                if (repo == null)
                {
                    context.Result = new BadRequestResult();
                }
                else
                {
                    var email = user.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
                    if (email == null)
                    {
                        context.Result = new UnauthorizedResult();
                    }
                    else
                    {
                        var userEntity = await repo.FindByEmailAsync(email);
                        if (userEntity == null)
                        {
                            context.Result = new UnauthorizedResult();
                        }
                        else
                        {
                            switch (_role)
                            {
                                case PermissionType.SuperAdmin when !userEntity.IsSuperAdmin:
                                case PermissionType.TenantAdmin when !userEntity.IsTenantAdmin:
                                case PermissionType.SuperAdminOrTenantAdmin:
                                {
                                    if (userEntity is {IsSuperAdmin: false, IsTenantAdmin: false})
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
}