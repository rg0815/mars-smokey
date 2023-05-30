using backend_system_service.Helper;
using backend_system_service.Models;
using backend_system_service.Models.MQTT;
using backend_system_service.MQTT;
using Microsoft.AspNetCore.Mvc;
using backend_system_service.Repositories;
using Core.Entities;
using Core.Helper;
using Microsoft.AspNetCore.Authorization;
using Newtonsoft.Json;

namespace backend_system_service.Controllers
{
    [Route("api/[controller]")]
    [ApiController, Authorize]
    public class GatewayController : BaseController
    {
        private readonly IGenericRepository<Gateway> _gatewayRepository;
        private readonly IGenericRepository<Tenant> _tenantRepository;
        private readonly IGenericRepository<Room> _roomRepository;
        private readonly IGenericRepository<BuildingUnit> _buildingUnitRepository;

        public GatewayController(IGenericRepository<Gateway> gatewayRepository,
            IGenericRepository<Tenant> tenantRepository, IGenericRepository<Room> roomRepository, IGenericRepository<BuildingUnit> buildingUnitRepository)
        {
            _gatewayRepository = gatewayRepository;
            _tenantRepository = tenantRepository;
            _roomRepository = roomRepository;
            _buildingUnitRepository = buildingUnitRepository;
        }
        
        // GET: api/Gateway
        [HttpGet]
        [Route("buildingUnit/{buildingUnitId}")]
        public ActionResult<IEnumerable<Gateway>> GetGatewaysInTenant(Guid buildingUnitId)
        {
            if (Roles == null) return Forbid();

           var buildingUnit = _buildingUnitRepository.GetById(buildingUnitId);
            if (buildingUnit == null)
            {
                return BadRequest(new ErrorDetails("BuildingUnit not found", ErrorCode.InvalidBuildingUnit));
            }

            if (Roles.IsSuperAdmin || Roles.IsTenantAdmin)
            {
                return Ok(_gatewayRepository
                    .GetAllByCondition(x => x.Room != null && x.Room.BuildingUnitId == buildingUnitId)
                    .OrderBy(x => x.Name));
            }

            var gateways = _gatewayRepository.GetAllByCondition(x =>
                    x.Room != null && (Roles.WriteBuildingUnitIds.Contains(x.Room.BuildingUnitId) ||
                                       Roles.ReadBuildingUnitIds.Contains(x.Room.BuildingUnitId)))
                .OrderBy(x => x.Name);

            return Ok(gateways);
        }
        

        // GET: api/Gateway
        [HttpGet]
        [Route("tenant/{tenantId?}")]
        public ActionResult<IEnumerable<Gateway>> GetGatewaysInTenant(string? tenantId)
        {
            if (Roles == null) return Forbid();

            var usedTenantId = Roles.TenantId;
            if (tenantId != null)
            {
                if (!Guid.TryParse(tenantId, out usedTenantId))
                {
                    return BadRequest(new ErrorDetails("Invalid tenant id", ErrorCode.InvalidTenantId));
                }
            }

            var tenant = _tenantRepository.GetById(usedTenantId);
            if (tenant == null)
            {
                return BadRequest(new ErrorDetails("Tenant not found", ErrorCode.InvalidTenantId));
            }

            if (Roles.IsSuperAdmin || Roles.IsTenantAdmin)
            {
                return Ok(_gatewayRepository
                    .GetAllByCondition(x => x.Room != null && x.Room.BuildingUnit.Building.TenantId == usedTenantId)
                    .OrderBy(x => x.Name));
            }

            var gateways = _gatewayRepository.GetAllByCondition(x =>
                    x.Room != null && (Roles.WriteBuildingUnitIds.Contains(x.Room.BuildingUnitId) ||
                                       Roles.ReadBuildingUnitIds.Contains(x.Room.BuildingUnitId)))
                .OrderBy(x => x.Name);

            return Ok(gateways);
        }

        // GET: api/Gateway/5
        [HttpGet("{id:guid}")]
        public ActionResult<Gateway> GetGateway(Guid id)
        {
            if (Roles == null) return Forbid();
            var gateway = _gatewayRepository.GetById(id);

            if (gateway == null)
            {
                return NotFound();
            }

            // if (!Guid.TryParse(gateway.RoomId.ToString(), out var roomId))
            //     return BadRequest(new ErrorDetails("Invalid room", ErrorCode.InvalidRoom));
            // var room = _roomRepository.GetById(roomId);
            // if (room == null)
            //     return BadRequest(new ErrorDetails("Invalid room", ErrorCode.InvalidRoom));
            //
            // if (!Guid.TryParse(room.BuildingUnitId.ToString(), out var buildingUnitId))
            //     return BadRequest(new ErrorDetails("Invalid building unit", ErrorCode.InvalidBuildingUnit));
            // var buildingUnit = _roomRepository.GetById(buildingUnitId);
            // if(buildingUnit == null)
            //     return BadRequest(new ErrorDetails("Invalid building unit", ErrorCode.InvalidBuildingUnit));

            // gateway.Room = room;

            if (!PermissionHelper.CheckPermission(Roles, Permission.Read, gateway))
            {
                return Forbid();
            }

            return Ok(gateway);
        }

        [HttpGet, Route("client/{clientId:guid}")]
        public ActionResult<Gateway> GetGatewayByClientId(Guid clientId)
        {
            if (Roles == null) return Forbid();
            var gateway = _gatewayRepository.GetByCondition(x => x.ClientId == clientId);

            if (gateway == null)
            {
                return NotFound();
            }

            return Ok(gateway);
        }

        // PUT: api/Gateway/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public IActionResult AddGateway(Guid id, GatewayUpdateRequest gateway)
        {
            if (Roles == null) return Forbid();
            var gw = _gatewayRepository.GetById(id);
            if (gw == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Update, gw))
            {
                return Forbid();
            }

            if (!Guid.TryParse(gateway.RoomId, out var roomGuid))
            {
                return BadRequest(new ErrorDetails("Invalid room id", ErrorCode.InvalidRoom));
            }

            var room = _roomRepository.GetById(roomGuid);
            gw.Room = room;
            gw.Name = gateway.Name;
            gw.Description = gateway.Description;
            gw.IsInitialized = true;
            _gatewayRepository.Update(gw);
            return Ok(gw);
        }

        [HttpPut, Route("client/{clientId:guid}")]
        public IActionResult PutGatewayByClientId(Guid clientId, GatewayUpdateRequest gateway)
        {
            if (Roles == null) return Forbid();
            var gw = _gatewayRepository.GetByCondition(x => x.ClientId == clientId);
            if (gw == null)
            {
                return NotFound();
            }

            if (!Guid.TryParse(gateway.RoomId, out var roomGuid))
            {
                return BadRequest(new ErrorDetails("Invalid room id", ErrorCode.InvalidRoom));
            }

            var room = _roomRepository.GetById(roomGuid);
            if (room == null)
                return BadRequest(new ErrorDetails("Invalid room id", ErrorCode.InvalidRoom));

            gw.Room = room;
            gw.Name = gateway.Name;
            gw.Description = gateway.Description;
            gw.IsInitialized = true;

            if (!PermissionHelper.CheckPermission(Roles, Permission.Update, gw))
            {
                return Forbid();
            }

            _gatewayRepository.Update(gw);

            var initMsg = new MqttMessage()
            {
                ClientId = clientId.ToString(),
                Action = MqttMessageAction.S_GatewayInitialized,
                Payload = MqttClient.SerializePayload("info", "GW is initialized")
            };

            var initJson = JsonConvert.SerializeObject(initMsg);
            Task.Run(() => MQTT.MqttClient.Publish("ssds/down/" + clientId, initJson));

            return Ok(gw);
        }


        // // POST: api/Gateway
        // // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        // [HttpPost("{roomId}")]
        // public ActionResult<Gateway> PostGateway(AddGenericRequest request, string roomId)
        // {
        //     if (Roles == null) return Forbid();
        //
        //     if (!Guid.TryParse(roomId, out var roomGuid))
        //     {
        //         return BadRequest(new ErrorDetails("Invalid room id", ErrorCode.InvalidRoom));
        //     }
        //
        //     var room = _roomRepository.GetById(roomGuid);
        //     if (room == null) return BadRequest(new ErrorDetails("Room not found", ErrorCode.InvalidRoom));
        //
        //     if (_gatewayRepository.GetByCondition(x => x.Room.Id == roomGuid && x.Name == request.Name) != null)
        //     {
        //         return BadRequest();
        //     }
        //
        //     var gateway = new Gateway
        //     {
        //         Name = request.Name,
        //         Description = request.Description,
        //         Password = Guid.NewGuid(),
        //         Room = room
        //     };
        //
        //     if (!PermissionHelper.CheckPermission(Roles, Permission.Create, gateway))
        //     {
        //         return Forbid();
        //     }
        //
        //     _gatewayRepository.Insert(gateway);
        //     return CreatedAtAction("GetGateway", new {id = gateway.Id}, gateway);
        // }

        // DELETE: api/Gateway/5
        [HttpDelete("{id:guid}")]
        public IActionResult DeleteGateway(Guid id)
        {
            if (Roles == null) return Forbid();
            var gateway = _gatewayRepository.GetById(id);
            if (gateway == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Delete, gateway))
            {
                return Forbid();
            }

            _gatewayRepository.Delete(gateway);
            return NoContent();
        }

        [HttpGet("startPairing")]
        public IActionResult StartPairing()
        {
            if (Roles == null) return Forbid();
            if (!Roles.IsSuperAdmin) return Forbid();

            var gateways = _gatewayRepository.GetAllByCondition(x => !x.IsInitialized);
            var gatewayIds = gateways.Select(gateway => gateway.ClientId.ToString()).ToList();
            MqttClient.ForceShowUsernames(gatewayIds);

            return Ok();
        }

        [HttpGet("stopPairing")]
        public IActionResult StopPairing()
        {
            if (Roles == null) return Forbid();
            if (!Roles.IsSuperAdmin) return Forbid();

            var gateways = _gatewayRepository.GetAllByCondition(x => !x.IsInitialized);
            var gatewayIds = gateways.Select(gateway => gateway.ClientId.ToString()).ToList();
            MqttClient.StopForceShowUsernames(gatewayIds);

            return Ok();
        }
    }
}