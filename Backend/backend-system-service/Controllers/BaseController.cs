using backend_system_service.Helper;
using Microsoft.AspNetCore.Mvc;

namespace backend_system_service.Controllers;

[ApiController]
public abstract class BaseController : ControllerBase
{
    protected UserModel? Roles => PermissionHelper.GetRole(User);
}