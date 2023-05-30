using backend_system_service.Helper;
using backend_system_service.Models;
using backend_system_service.MQTT;
using Microsoft.AspNetCore.Mvc;
using backend_system_service.Repositories;
using Core.Entities;
using Core.Helper;
using Microsoft.AspNetCore.Authorization;

namespace backend_system_service.Controllers
{
    [Route("api/[controller]")]
    [ApiController, Authorize]
    public class SmokeDetectorController : BaseController
    {
        private readonly IGenericRepository<SmokeDetector> _smokeDetectorRepository;
        private readonly IGenericRepository<SmokeDetectorModel> _smokeDetectorModelRepository;
        private readonly IGenericRepository<FireAlarm> _fireAlarmRepository;
        private readonly IGenericRepository<BuildingUnit> _buildingUnitRepository;
        private readonly IGenericRepository<Gateway> _gatewayRepository;
        private readonly IGenericRepository<Room> _roomRepository;
        private readonly IGenericRepository<Tenant> _tenantRepository;

        public SmokeDetectorController(IGenericRepository<SmokeDetector> smokeDetectorRepository,
            IGenericRepository<SmokeDetectorModel> smokeDetectorModelRepository,
            IGenericRepository<Room> roomRepository,
            IGenericRepository<BuildingUnit> buildingUnitRepository, IGenericRepository<Gateway> gatewayRepository,
            IGenericRepository<Tenant> tenantRepository, IGenericRepository<FireAlarm> fireAlarmRepository)
        {
            _smokeDetectorRepository = smokeDetectorRepository;
            _smokeDetectorModelRepository = smokeDetectorModelRepository;
            _roomRepository = roomRepository;
            _buildingUnitRepository = buildingUnitRepository;
            _gatewayRepository = gatewayRepository;
            _tenantRepository = tenantRepository;
            _fireAlarmRepository = fireAlarmRepository;
        }

        // GET: api/SmokeDetector/5
        [HttpGet("{id:guid}")]
        public ActionResult<SmokeDetector> GetSmokeDetector(Guid id)
        {
            if (Roles == null) return Forbid();
            var smokeDetector = _smokeDetectorRepository.GetById(id);

            if (smokeDetector == null)
            {
                return NotFound();
            }

            //if smokedetector is not initialized, it has the same room as the gateway
            if (smokeDetector.RoomId == null)
            {
                return NotFound();
            }

            var room = _roomRepository.GetById(smokeDetector.RoomId.Value);
            if (room == null)
            {
                return NotFound();
            }

            var buildingUnit = _buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null)
            {
                return NotFound();
            }

            var tempCheck = smokeDetector;
            tempCheck.Room = room;
            tempCheck.Room.BuildingUnit = buildingUnit;

            if (!PermissionHelper.CheckPermission(Roles, Permission.Read, tempCheck))
            {
                return Forbid();
            }

            return smokeDetector;
        }

        [HttpGet]
        [Route("tenant/{tenantId:guid?}")]
        public ActionResult<IEnumerable<SmokeDetector>> GetSmokeDetectors(Guid? tenantId)
        {
            if (Roles == null) return Forbid();

            var usedTenantId = Roles.TenantId;
            if (tenantId != null)
            {
                usedTenantId = tenantId.Value;
            }

            var tenant = _tenantRepository.GetById(usedTenantId);
            if (tenant == null)
            {
                return BadRequest(new ErrorDetails("Tenant not found", ErrorCode.InvalidTenantId));
            }

            if (Roles.IsSuperAdmin || Roles.IsTenantAdmin)
            {
                var detectors = _smokeDetectorRepository
                    .GetAllByCondition(x => x.Room != null && x.Room.BuildingUnit.Building.TenantId == usedTenantId)
                    .Where(x =>
                        x.Name != "NEW SMOKE DETECTOR" && x.Description != "NEW SMOKE DETECTOR")
                    .OrderBy(x => x.Name);

                return Ok(detectors);
            }

            var smokeDetectors = _smokeDetectorRepository.GetAllByCondition(x =>
                    x.Room != null && (Roles.WriteBuildingUnitIds.Contains(x.Room.BuildingUnitId) ||
                                       Roles.ReadBuildingUnitIds.Contains(x.Room.BuildingUnitId))).Where(x =>
                    x.Name != "NEW SMOKE DETECTOR" && x.Description != "NEW SMOKE DETECTOR")
                .OrderBy(x => x.Name);

            return Ok(smokeDetectors);
        }

        // PUT: api/SmokeDetector/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public IActionResult PutSmokeDetector(Guid id, SmokeDetectorInitRequest smokeDetector)
        {
            if (Roles == null) return Forbid();
            var existingSmokeDetector = _smokeDetectorRepository.GetById(id);

            if (existingSmokeDetector == null)
            {
                return NotFound();
            }

            var room = _roomRepository.GetById(smokeDetector.RoomId);
            if (room == null) return BadRequest();

            var model = _smokeDetectorModelRepository.GetById(smokeDetector.SmokeDetectorModelId);
            if (model == null) return BadRequest();

            existingSmokeDetector.Room = room;
            existingSmokeDetector.Name = smokeDetector.Name;
            existingSmokeDetector.Description = smokeDetector.Description;
            existingSmokeDetector.SmokeDetectorModel = model;
            existingSmokeDetector.LastMaintenance = DateTime.UtcNow;

            if (!Roles.WriteBuildingUnitIds.Contains(existingSmokeDetector.Room.BuildingUnitId)
                && !Roles.IsSuperAdmin && !Roles.IsTenantAdmin) return Forbid();
            _smokeDetectorRepository.Update(existingSmokeDetector);
            return Ok(existingSmokeDetector);
        }

        // DELETE: api/SmokeDetector/5
        [HttpDelete("{id}")]
        public IActionResult DeleteSmokeDetector(Guid id)
        {
            if (Roles == null) return Forbid();

            var smokeDetector = _smokeDetectorRepository.GetById(id);
            if (smokeDetector == null)
            {
                return NotFound();
            }

            if (smokeDetector.RoomId == null) return BadRequest();

            var room = _roomRepository.GetById(smokeDetector.RoomId.Value);
            if (room == null) return BadRequest();

            var buildingUnit = _buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null) return BadRequest();

            var tempCheck = smokeDetector;
            tempCheck.Room = room;
            tempCheck.Room.BuildingUnit = buildingUnit;

            if (!Roles.WriteBuildingUnitIds.Contains(tempCheck.Room.BuildingUnitId) &&
                !Roles.IsSuperAdmin && !Roles.IsTenantAdmin) return Forbid();

            _smokeDetectorRepository.Delete(smokeDetector);
            return NoContent();
        }

        [HttpGet]
        [Route("models")]
        public ActionResult<IEnumerable<SmokeDetectorModel>> GetSmokeDetectorModels()
        {
            if (Roles == null) return Forbid();
            var smokeDetectorModels = _smokeDetectorModelRepository.GetAll();
            if (smokeDetectorModels.Any()) return Ok(smokeDetectorModels);


            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("Smartwares", "RM175RF",
                CommunicationType.Mhz433, 12, 12,
                SmokeDetectorProtocol.Rm175Rf)
            {
                Name = "Smartwares"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("Smartwares", "10.041.05",
                CommunicationType.Mhz433, 12, 12,
                SmokeDetectorProtocol.Rm175Rf)
            {
                Name = "Smartwares"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("modern-electronics", "GS 558",
                CommunicationType.Mhz433,
                12, 12,
                SmokeDetectorProtocol.Rm175Rf)
            {
                Name = "modern-electronics"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("ATEK", "GS-558", CommunicationType.Mhz433,
                12, 12,
                SmokeDetectorProtocol.Rm175Rf)
            {
                Name = "ATEK"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("SEBSON", "GS558", CommunicationType.Mhz433,
                12, 12,
                SmokeDetectorProtocol.Rm175Rf)
            {
                Name = "SEBSON"
            });

            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("Smartwares", "FA22RF",
                CommunicationType.Mhz433, 12, 12,
                SmokeDetectorProtocol.Fa22Rf)
            {
                Name = "Smartwares"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("Smartwares", "FA21RF",
                CommunicationType.Mhz433, 12, 12,
                SmokeDetectorProtocol.Fa22Rf)
            {
                Name = "Smartwares"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("Smartwares", "FA20RF",
                CommunicationType.Mhz433, 12, 12,
                SmokeDetectorProtocol.Fa22Rf)
            {
                Name = "Smartwares"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("profitec", "KD101LA", CommunicationType.Mhz433,
                12, 12, SmokeDetectorProtocol.Fa22Rf)
            {
                Name = "profitec"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("POLLING", "KD101LA", CommunicationType.Mhz433,
                12, 12, SmokeDetectorProtocol.Fa22Rf)
            {
                Name = "POLLING"
            });
            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("Renkforce", "LM-101LD",
                CommunicationType.Mhz433,
                12, 12, SmokeDetectorProtocol.Fa22Rf)
            {
                Name = "Renkforce"
            });

            _smokeDetectorModelRepository.Insert(new SmokeDetectorModel("Cavius", "Funkrauchmelder",
                CommunicationType.Cavius, 12, 12, SmokeDetectorProtocol.Cavius)
            {
                Name = "Cavius"
            });

            _smokeDetectorModelRepository.Insert(
                new SmokeDetectorModel("frient", "SMSZB-120", CommunicationType.Zigbee, 12, 12,
                    SmokeDetectorProtocol.Zigbee)
                {
                    Name = "frient"
                });


            smokeDetectorModels = _smokeDetectorModelRepository.GetAll();

            return Ok(smokeDetectorModels);
        }

        [HttpPost]
        [Route("alarm/stop/{fireAlarmId:guid}")]
        public ActionResult StopAlarm(Guid fireAlarmId)
        {
            if (Roles == null) return Forbid();
            var fireAlarm = _fireAlarmRepository.GetById(fireAlarmId);
            if (fireAlarm == null) return NotFound();

            if (!Roles.WriteBuildingUnitIds.Contains(fireAlarm.BuildingUnitId) && !Roles.IsTenantAdmin &&
                !Roles.IsSuperAdmin)
                return Forbid();

            var gateways = _gatewayRepository.GetAllByCondition(x => x.Room.BuildingUnitId == fireAlarm.BuildingUnitId);

            fireAlarm.EndTime = DateTime.UtcNow;
            _fireAlarmRepository.Update(fireAlarm);


            foreach (var gw in gateways)
            {
                foreach (var detectorAlarm in fireAlarm.AlarmedDetectors)
                {
                    var sd = detectorAlarm.SmokeDetector;
                    sd.State = SmokeDetectorState.Normal;
                    _smokeDetectorRepository.Update(sd);


                    if (!sd.SmokeDetectorModel.SupportsRemoteAlarm) continue;


                    if (sd.SmokeDetectorModel != null)
                        if (sd.RawTransmissionData != null)
                            MqttClient.StopAlarm(gw.ClientId.ToString(),
                                sd.SmokeDetectorModel,
                                sd.RawTransmissionData);
                }
            }

            return Ok();
        }

        [HttpPost]
        [Route("alarm/test/{smokeDetectorId:guid}")]
        public ActionResult PerformTestAlarm(Guid smokeDetectorId)
        {
            if (Roles == null) return Forbid();
            var smokeDetector = _smokeDetectorRepository.GetById(smokeDetectorId);
            if (smokeDetector == null) return NotFound();

            if (smokeDetector.Room != null && !Roles.WriteBuildingUnitIds.Contains(smokeDetector.Room.BuildingUnitId) &&
                !Roles.IsTenantAdmin &&
                !Roles.IsSuperAdmin) return Forbid();

            if (smokeDetector.RoomId == null) return BadRequest();

            var room = _roomRepository.GetById(smokeDetector.RoomId.Value);
            if (room == null) return NotFound();
            var buildingUnit = _buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null) return NotFound();

            var gwList = new List<Gateway>();
            foreach (var buildingUnitRoom in buildingUnit.Rooms)
            {
                gwList.AddRange(_gatewayRepository.GetAllByCondition(x => x.RoomId == buildingUnitRoom.Id));
            }

            foreach (var gw in gwList)
            {
                if (smokeDetector.SmokeDetectorModel != null)
                    if (smokeDetector.RawTransmissionData != null)
                        MqttClient.PerformAlarm(gw.ClientId.ToString(),
                            smokeDetector.SmokeDetectorModel,
                            smokeDetector.RawTransmissionData);
            }

            return Ok();
        }

        [HttpPost]
        [Route("alarm/stop-test/{smokeDetectorId:guid}")]
        public ActionResult StopTestAlarm(Guid smokeDetectorId)
        {
            if (Roles == null) return Forbid();
            var smokeDetector = _smokeDetectorRepository.GetById(smokeDetectorId);
            if (smokeDetector == null) return NotFound();

            if (smokeDetector.RoomId == null || smokeDetector.Room == null) return BadRequest();

            if (!Roles.WriteBuildingUnitIds.Contains(smokeDetector.Room.BuildingUnitId) && !Roles.IsTenantAdmin &&
                !Roles.IsSuperAdmin) return Forbid();


            var room = _roomRepository.GetById(smokeDetector.RoomId.Value);
            if (room == null) return NotFound();
            var buildingUnit = _buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null) return NotFound();

            var gwList = new List<Gateway>();
            foreach (var buildingUnitRoom in buildingUnit.Rooms)
            {
                gwList.AddRange(_gatewayRepository.GetAllByCondition(x => x.RoomId == buildingUnitRoom.Id));
            }

            foreach (var gw in gwList)
            {
                if (smokeDetector.SmokeDetectorModel != null)
                    if (smokeDetector.RawTransmissionData != null)
                        MqttClient.StopAlarm(gw.ClientId.ToString(),
                            smokeDetector.SmokeDetectorModel,
                            smokeDetector.RawTransmissionData);
            }

            return Ok();
        }

        [HttpPost]
        [Route("pairing/start/{gatewayId:guid}")]
        public ActionResult StartPairing(Guid gatewayId)
        {
            if (Roles == null) return Forbid();

            var gateway = _gatewayRepository.GetById(gatewayId);
            if (gateway?.RoomId == null) return NotFound();
            var room = _roomRepository.GetById(gateway.RoomId.Value);
            if (room == null) return NotFound();
            var buildingUnit = _buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null) return NotFound();

            MqttClient.RegisteredUpdateUsers.TryAdd(Roles.UserId, new Tuple<Guid, UserModel>(gateway.Id, Roles));

            if (!Roles.WriteBuildingUnitIds.Contains(buildingUnit.Id) && !Roles.IsTenantAdmin && !Roles.IsSuperAdmin)
                return Forbid();

            MqttClient.StartPairing(gateway.ClientId.ToString());

            return Ok();
        }

        [HttpPost]
        [Route("pairing/stop/{gatewayId:guid}")]
        public ActionResult StopPairing(Guid gatewayId)
        {
            if (Roles == null) return Forbid();

            var gateway = _gatewayRepository.GetById(gatewayId);
            if (gateway?.RoomId == null) return NotFound();
            var room = _roomRepository.GetById(gateway.RoomId.Value);
            if (room == null) return NotFound();
            var buildingUnit = _buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null) return NotFound();

            if (!Roles.WriteBuildingUnitIds.Contains(buildingUnit.Id) && !Roles.IsTenantAdmin && !Roles.IsSuperAdmin)
                return Forbid();

            MqttClient.RegisteredUpdateUsers.TryRemove(Roles.UserId, out _);
            MqttClient.StopPairing(gateway.ClientId.ToString());

            return Ok();
        }

        [HttpPost, Route("maintenance/{smokeDetectorId:guid}")]
        public ActionResult CreateNewMaintenance(Guid smokeDetectorId, AddSmokeDetectorMaintenanceRequest model)
        {
            if (Roles == null) return Forbid();

            var smokeDetector = _smokeDetectorRepository.GetById(smokeDetectorId);
            if (smokeDetector == null) return NotFound();

            if (smokeDetector.Room != null && !Roles.WriteBuildingUnitIds.Contains(smokeDetector.Room.BuildingUnitId) &&
                !Roles.IsTenantAdmin &&
                !Roles.IsSuperAdmin) return Forbid();

            if (smokeDetector.RoomId == null) return BadRequest();

            var room = _roomRepository.GetById(smokeDetector.RoomId.Value);
            if (room == null) return NotFound();
            var buildingUnit = _buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null) return NotFound();

            var maintenance = new SmokeDetectorMaintenance()
            {
                SmokeDetectorId = smokeDetector.Id,
                Signature = model.Signature,
                IsCleaned = model.IsCleaned,
                IsBatteryReplaced = model.IsBatteryReplaced,
                IsDustCleaned = model.IsDustCleaned,
                UserId = Roles.UserId,
                IsTested = model.IsTested,
                Time = DateTime.UtcNow,
                Comment = model.Comment
            };

            if (maintenance.IsCleaned || maintenance.IsDustCleaned || maintenance.IsTested)
            {
                smokeDetector.LastMaintenance = maintenance.Time;
            }

            if (maintenance.IsBatteryReplaced)
            {
                smokeDetector.LastBatteryReplacement = maintenance.Time;
            }

            smokeDetector.Maintenances.Add(maintenance);
            _smokeDetectorRepository.Update(smokeDetector);
            return Ok();
        }
    }
}