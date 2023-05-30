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
    public class BuildingUnitController : BaseController
    {
        private readonly IGenericRepository<BuildingUnit> _buildingUnitRepository;
        private readonly IGenericRepository<Building> _buildingRepository;

        public BuildingUnitController(IGenericRepository<BuildingUnit> buildingUnitRepository,
            IGenericRepository<Building> buildingRepository)
        {
            _buildingUnitRepository = buildingUnitRepository;
            _buildingRepository = buildingRepository;
        }

        
        // GET: api/BuildingUnit/tenant/5
        [HttpGet("tenant/{tenantId}")]
        [Authorize, Permission(PermissionType.SuperAdminOrTenantAdmin)]
        public async Task<ActionResult<List<BuildingUnit>>> GetBuildingUnityByTenant(string tenantId)
        {
            if (Roles == null) return Forbid();
            var buildingUnits = _buildingUnitRepository.GetAllByCondition(x => x.Building.TenantId == Guid.Parse(tenantId));
            return Ok(buildingUnits);
        }

        // GET: api/BuildingUnit/5
        [HttpGet("{id}")]
        public async Task<ActionResult<BuildingUnit>> GetBuildingUnit(Guid id)
        {
            if (Roles == null) return Forbid();
            var buildingUnit = _buildingUnitRepository.GetById(id);

            if (buildingUnit == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Read, buildingUnit))
                return Forbid();
            
            return Ok(buildingUnit);
        }

        // PUT: api/BuildingUnit/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutBuildingUnit(Guid id, BasicUpdateRequest buildingUnit)
        {
            if (Roles == null) return Forbid();
            var existingBuildingUnit = _buildingUnitRepository.GetById(id);
            if (existingBuildingUnit == null)
            {
                return NotFound();
            }
            
            existingBuildingUnit.Name = buildingUnit.Name;
            existingBuildingUnit.Description = buildingUnit.Description;
            
            if (!PermissionHelper.CheckPermission(Roles, Permission.Update, buildingUnit))
                return Forbid();
            
            _buildingUnitRepository.Update(existingBuildingUnit);
            return Ok(GetBuildingUnit(existingBuildingUnit.Id));
        }

        // POST: api/BuildingUnit
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("{buildingId}")]
        public async Task<ActionResult<BuildingUnit>> PostBuildingUnit(AddGenericRequest request,
            string buildingId)
        {
            if (Roles == null) return Forbid();
            var building = _buildingRepository.GetById(Guid.Parse(buildingId));
            if (building == null) return NotFound();

            if (_buildingUnitRepository.GetByCondition(x => x.Name == request.Name && x.Building == building) != null)
            {
                return Conflict();
            }

            var buildingUnit = new BuildingUnit
            {
                Name = request.Name,
                Description = request.Description,
                Building = building,
                FireAlarms = new List<FireAlarm>(),
                Rooms = new List<Room>(),
            };

            if(!PermissionHelper.CheckPermission(Roles, Permission.Create, buildingUnit))
                return Forbid();

            _buildingUnitRepository.Insert(buildingUnit);
            return CreatedAtAction("GetBuildingUnit", new {id = buildingUnit.Id}, buildingUnit);
        }

        // DELETE: api/BuildingUnit/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBuildingUnit(Guid id)
        {
            if (Roles == null) return Forbid();
            var buildingUnit = _buildingUnitRepository.GetById(id);
            if (buildingUnit == null)
            {
                return NotFound();
            }

            if(!PermissionHelper.CheckPermission(Roles, Permission.Delete, buildingUnit))
                return Forbid();
            
            _buildingUnitRepository.Delete(buildingUnit);
            return NoContent();
        }
    }
}