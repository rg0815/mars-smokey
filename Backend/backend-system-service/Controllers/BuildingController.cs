using Microsoft.AspNetCore.Mvc;
using backend_system_service.Helper;
using backend_system_service.Models;
using backend_system_service.Repositories;
using Core.Entities;
using Core.Helper;
using Microsoft.AspNetCore.Authorization;

namespace backend_system_service.Controllers
{
    [Route("api/[controller]")]
    [ApiController, Authorize]
    public class BuildingController : BaseController
    {
        private readonly IGenericRepository<Building> _buildingRepository;
        private readonly IGenericRepository<Tenant> _tenantRepository;

        public BuildingController(IGenericRepository<Building> buildingRepository,
            IGenericRepository<Tenant> tenantRepository)
        {
            _buildingRepository = buildingRepository;
            _tenantRepository = tenantRepository;
        }

        // GET: api/Building
        [HttpGet]
        [Authorize]
        [Permission(PermissionType.SuperAdminOrTenantAdmin)]
        public ActionResult<IEnumerable<Building>> GetBuildings()
        {
            if (Roles == null) return Forbid();
            return Ok(Roles.IsSuperAdmin
                ? _buildingRepository.GetAll().OrderBy(x => x.Name)
                : _buildingRepository.GetAllByCondition(x => x.TenantId == Roles.TenantId).OrderBy(x => x.Name));
        }

        // GET: api/Building/5
        [HttpGet("{id:guid}")]
        [Authorize]
        [Permission(PermissionType.SuperAdminOrTenantAdmin)]
        public ActionResult<Building> GetBuilding(Guid id)
        {
            if (Roles == null) return Forbid();
            var building = _buildingRepository.GetById(id);
            if (building == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Read, building))
            {
                return Forbid();
            }

            return Ok(building);
        }

        // PUT: api/Building/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public IActionResult PutBuilding(Guid id, BasicUpdateRequest building)
        {
            if (Roles == null) return Forbid();
            var existingBuilding = _buildingRepository.GetById(id);
            if (existingBuilding == null)
            {
                return NotFound();
            }

            existingBuilding.Name = building.Name;
            existingBuilding.Description = building.Description;

            if (!PermissionHelper.CheckPermission(Roles, Permission.Update, existingBuilding))
            {
                return Forbid();
            }

            _buildingRepository.Update(existingBuilding);
            return Ok(existingBuilding);
        }

        // POST: api/Building/{tenantId}
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("{tenantId}")]
        public async Task<ActionResult<Building>> PostBuilding(AddBuildingRequest request, string tenantId)
        {
            if (Roles == null) return Forbid();
            var tenant = _tenantRepository.GetById(Guid.Parse(tenantId));
            if (tenant == null)
            {
                return NotFound();
            }

            var address = new Address()
            {
                Street = request.Street,
                City = request.City,
                ZipCode = request.ZipCode,
                Country = request.Country
            };

            var building = new Building
            {
                Name = request.BuildingName,
                Description = request.BuildingDescription,
                Address = address,
                Tenant = tenant,
                BuildingUnits = new List<BuildingUnit>()
            };

            if (!PermissionHelper.CheckPermission(Roles, Permission.Create, building))
            {
                return Forbid();
            }

            if (_buildingRepository.GetByCondition(x => x.Name == building.Name) != null)
            {
                return BadRequest();
            }

            _buildingRepository.Insert(building);
            return CreatedAtAction("GetBuilding", new {id = building.Id}, building);
        }

        // DELETE: api/Building/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBuilding(Guid id)
        {
            if (Roles == null) return Forbid();
            var building = _buildingRepository.GetById(id);
            if (building == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Delete, building))
            {
                return Forbid();
            }

            _buildingRepository.Delete(building);
            return NoContent();
        }
    }
}