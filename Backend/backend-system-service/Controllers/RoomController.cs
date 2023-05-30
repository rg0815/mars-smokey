using backend_system_service.Helper;
using backend_system_service.Models;
using Microsoft.AspNetCore.Mvc;
using backend_system_service.Repositories;
using Core.Entities;
using Microsoft.AspNetCore.Authorization;

namespace backend_system_service.Controllers
{
    [Route("api/[controller]")]
    [ApiController, Authorize]
    public class RoomController : BaseController
    {
        private readonly IGenericRepository<Room> _roomRepository;
        private readonly IGenericRepository<BuildingUnit> _buildingUnitRepository;

        public RoomController(IGenericRepository<Room> roomRepository,
            IGenericRepository<BuildingUnit> buildingUnitRepository)
        {
            _roomRepository = roomRepository;
            _buildingUnitRepository = buildingUnitRepository;
        }

        // GET: api/Room/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Room>> GetRoom(Guid id)
        {
            if (Roles == null) return Forbid();
            var room = _roomRepository.GetById(id);
            if (room == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Read, room))
                return Forbid();

            return Ok(room);
        }

        // PUT: api/Room/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutRoom(Guid id, BasicUpdateRequest room)
        {
            if (Roles == null) return Forbid();
            var existingRoom = _roomRepository.GetById(id);
            if (existingRoom == null)
            {
                return NotFound();
            }

            existingRoom.Name = room.Name;
            existingRoom.Description = room.Description;

            if (!PermissionHelper.CheckPermission(Roles, Permission.Update, room))
                return Forbid();

            _roomRepository.Update(existingRoom);
            return Ok(GetRoom(existingRoom.Id));
        }

        // POST: api/Room
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("{buildingUnitId}")]
        public async Task<ActionResult<Room>> PostRoom(AddGenericRequest req, string buildingUnitId)
        {
            if (Roles == null) return Forbid();
            var buildingUnit = _buildingUnitRepository.GetById(Guid.Parse(buildingUnitId));
            if (buildingUnit == null) return NotFound();

            if (_roomRepository.GetByCondition(x => x.Name == req.Name && x.BuildingUnitId == buildingUnit.Id) != null)
            {
                return BadRequest();
            }

            var room = new Room
            {
                Name = req.Name,
                Description = req.Description,
                BuildingUnit = buildingUnit,
                Gateways = new List<Gateway>(),
                SmokeDetectors = new List<SmokeDetector>()
            };

            if (!PermissionHelper.CheckPermission(Roles, Permission.Create, room))
                return Forbid();

            _roomRepository.Insert(room);
            return CreatedAtAction("GetRoom", new {id = room.Id}, room);
        }

        // DELETE: api/Room/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRoom(Guid id)
        {
            if (Roles == null) return Forbid();
            var room = _roomRepository.GetById(id);
            if (room == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Delete, room))
                return Forbid();

            _roomRepository.Delete(room);
            return NoContent();
        }
    }
}