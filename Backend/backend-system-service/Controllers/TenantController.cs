using backend_system_service.Helper;
using Microsoft.AspNetCore.Mvc;
using backend_system_service.Models;
using backend_system_service.Repositories;
using backend_system_service.Services;
using Core.Entities;
using Core.Helper;
using Microsoft.AspNetCore.Authorization;

namespace backend_system_service.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TenantController : BaseController
    {
        private readonly IGenericRepository<Tenant> _tenantRepository;

        public TenantController(IGenericRepository<Tenant> tenantRepository)
        {
            _tenantRepository = tenantRepository;
        }

        [HttpGet]
        [Authorize]
        [Permission(PermissionType.SuperAdminOrTenantAdmin)]
        public ActionResult<IEnumerable<Tenant>> GetAllTenants()
        {
            if (Roles == null) return Forbid();
            if (Roles.IsSuperAdmin)
            {
                var models = _tenantRepository.GetAll().OrderBy(x => x.Name);
                return Ok(models);
            }
            else
            {
                var models = _tenantRepository.GetAllByCondition(x => x.Id == Roles.TenantId).OrderBy(x => x.Name);
                return Ok(models);
            }
        }

        // GET: api/Tenant/5
        [HttpGet("{id}")]
        [Authorize]
        [Permission(PermissionType.SuperAdminOrTenantAdmin)]
        public ActionResult<Tenant> GetTenantById(Guid id)
        {
            if (Roles == null) return Forbid();

            var tenant = _tenantRepository.GetById(id);
            if (tenant == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Read, tenant))
            {
                return Forbid();
            }

            return Ok(tenant);
        }

        // PUT: api/Tenant/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id:guid}")]
        [Authorize]
        public IActionResult UpdateTenant(Guid id, BasicUpdateRequest tenant)
        {
            if (Roles == null) return Forbid();

            var existingTenant = _tenantRepository.GetById(id);
            if (existingTenant == null)
            {
                return NotFound();
            }

            existingTenant.Name = tenant.Name;
            existingTenant.Description = tenant.Description;


            if (!PermissionHelper.CheckPermission(Roles, Permission.Update, existingTenant))
            {
                return Forbid();
            }

            _tenantRepository.Update(existingTenant);
            return Ok(existingTenant);
        }

        // POST: api/Tenant
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        [AllowAnonymous]
        public ActionResult<Tenant> CreateTenant(Tenant tenant)
        {
            if (_tenantRepository.GetByCondition(x => x.Name == tenant.Name) != null)
            {
                return BadRequest(new ErrorDetails("Tenant already exists", ErrorCode.TenantAlreadyExists));
            }

            _tenantRepository.Insert(tenant);
            return Ok(tenant);
        }

        // DELETE: api/Tenant/5
        [HttpDelete("{id:guid}")]
        [Permission(PermissionType.SuperAdmin)]
        public IActionResult DeleteTenant(Guid id)
        {
            if (Roles == null) return Forbid();
            var tenant = _tenantRepository.GetById(id);
            if (tenant == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Delete, tenant))
            {
                return Forbid();
            }

            _tenantRepository.Delete(tenant);
            return NoContent();
        }
    }
}