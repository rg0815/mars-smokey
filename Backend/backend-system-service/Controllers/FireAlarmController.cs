using backend_system_service.MQTT;
using backend_system_service.Repositories;
using Core.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace backend_system_service.Controllers;

[Route("api/[controller]")]
[ApiController, Authorize]
public class FireAlarmController : BaseController
{
    private readonly IGenericRepository<FireAlarm> _fireAlarmRepository;
    private readonly IGenericRepository<Gateway> _gatewayRepository;
    private readonly IGenericRepository<SmokeDetector> _smokeDetectorRepository;
    private readonly IGenericRepository<BuildingUnit> _buildingUnitRepository;


    public FireAlarmController(IGenericRepository<FireAlarm> fireAlarmRepository,
        IGenericRepository<Gateway> gatewayRepository, IGenericRepository<SmokeDetector> smokeDetectorRepository,
        IGenericRepository<BuildingUnit> buildingUnitRepository)
    {
        _fireAlarmRepository = fireAlarmRepository;
        _gatewayRepository = gatewayRepository;
        _smokeDetectorRepository = smokeDetectorRepository;
        _buildingUnitRepository = buildingUnitRepository;
    }

    [HttpGet, Route("check/{tenantId:guid?}")]
    public ActionResult CheckAnyAlarms(Guid? tenantId)
    {
        if (Roles == null) return Forbid();
        if (tenantId.HasValue && !Roles.IsSuperAdmin) return Forbid();
        if (tenantId.HasValue && Roles.IsSuperAdmin)
        {
            var res = _fireAlarmRepository.GetAllByCondition(x =>
                x.EndTime == DateTime.MinValue && x.BuildingUnit.Building.TenantId == tenantId);
            if (res.Any())
            {
                return Ok();
            }

            return NotFound();
        }

        if (Roles.IsTenantAdmin)
        {
            var res = _fireAlarmRepository.GetAllByCondition(x =>
                x.EndTime == DateTime.MinValue && x.BuildingUnit.Building.TenantId == Roles.TenantId);
            if (res.Any())
            {
                return Ok();
            }

            return NotFound();
        }

        var alarms = _fireAlarmRepository.GetAllByCondition(x =>
            x.EndTime == DateTime.MinValue && Roles.ReadBuildingUnitIds.Contains(x.BuildingUnitId));
        if (alarms.Any())
        {
            return Ok();
        }

        return NotFound();
    }

    [HttpGet, Route("{tenantId:guid?}")]
    public ActionResult<List<FireAlarm>> GetAllFireAlarms(Guid? tenantId)
    {
        if (Roles == null) return Forbid();
        if (tenantId.HasValue && !Roles.IsSuperAdmin) return Forbid();
        if (tenantId.HasValue && Roles.IsSuperAdmin)
        {
            var bUnits = _buildingUnitRepository.GetAllByCondition(x => x.Building.TenantId == tenantId);
            List<FireAlarm> tenantAlarms = new();
            foreach (var bUnit in bUnits)
            {
                tenantAlarms.AddRange(_fireAlarmRepository.GetAllByCondition(
                    x => x.BuildingUnitId == bUnit.Id));
            }

            return Ok(tenantAlarms);
        }

        if (Roles.IsTenantAdmin)
        {
            var bUnits = _buildingUnitRepository.GetAllByCondition(x => x.Building.TenantId == Roles.TenantId);
            List<FireAlarm> tenantAlarms = new();
            foreach (var bUnit in bUnits)
            {
                tenantAlarms.AddRange(_fireAlarmRepository.GetAllByCondition(
                    x => x.BuildingUnitId == bUnit.Id));
            }

            return Ok(tenantAlarms);
        }

        var alarms = _fireAlarmRepository.GetAllByCondition(x => Roles.ReadBuildingUnitIds.Contains(x.BuildingUnitId));
        return Ok(alarms);
    }

    [HttpGet, Route("active/{tenantId:guid?}")]
    public ActionResult<List<FireAlarm>> GetActiveFireAlarms(Guid? tenantId)
    {
        if (Roles == null) return Forbid();
        if (tenantId.HasValue && !Roles.IsSuperAdmin) return Forbid();
        if (tenantId.HasValue && Roles.IsSuperAdmin)
        {
            var bUnits = _buildingUnitRepository.GetAllByCondition(x => x.Building.TenantId == tenantId);
            List<FireAlarm> tenantAlarms = new();
            foreach (var bUnit in bUnits)
            {
                tenantAlarms.AddRange(_fireAlarmRepository.GetAllByCondition(
                    x => x.EndTime == DateTime.MinValue && x.BuildingUnitId == bUnit.Id));
            }

            return Ok(tenantAlarms);
        }

        if (Roles.IsTenantAdmin)
        {
            var bUnits = _buildingUnitRepository.GetAllByCondition(x => x.Building.TenantId == Roles.TenantId);
            List<FireAlarm> tenantAlarms = new();
            foreach (var bUnit in bUnits)
            {
                tenantAlarms.AddRange(_fireAlarmRepository.GetAllByCondition(
                    x => x.EndTime == DateTime.MinValue && x.BuildingUnitId == bUnit.Id));
            }

            return Ok(tenantAlarms);
        }

        var alarms =
            _fireAlarmRepository.GetAllByCondition(x =>
                x.IsActive() && Roles.ReadBuildingUnitIds.Contains(x.BuildingUnitId));
        return Ok(alarms);
    }

    [HttpPost]
    [Route("stop/{fireAlarmId:guid}")]
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

        foreach (var smokeDetectorAlarm in fireAlarm.AlarmedDetectors)
        {
           var detector = _smokeDetectorRepository.GetById(smokeDetectorAlarm.SmokeDetectorId);
           if (detector != null)
           {
               detector.State = SmokeDetectorState.Normal;
               _smokeDetectorRepository.Update(detector);
           }
        }

        var buildingUnit = _buildingUnitRepository.GetById(fireAlarm.BuildingUnitId);

        var evacuate = _fireAlarmRepository.GetAllByCondition(x =>
                x.EndTime == DateTime.MinValue && x.BuildingUnit.BuildingId == buildingUnit.BuildingId)
            .Count() >= 2;

        // if evacuate is true, let the fire alarm ring
        if (evacuate) return Ok();

        var buildingUnits = _buildingUnitRepository.GetAllByCondition(x =>
            x.BuildingId == buildingUnit.BuildingId);

        foreach (var bUnit in buildingUnits)
        {
            var buildingGws = _gatewayRepository.GetAllByCondition(x =>
                x.Room.BuildingUnitId == bUnit.Id);
            var buildingSds = _smokeDetectorRepository.GetAllByCondition(x =>
               x.Room.BuildingUnitId == bUnit.Id &&
                x.SmokeDetectorModel.SupportsRemoteAlarm);

            foreach (var gw in buildingGws)
            {
                foreach (var sd in buildingSds)
                {
                    MqttClient.StopAlarm(gw.ClientId.ToString(),
                        sd.SmokeDetectorModel,
                        sd.RawTransmissionData);
                }
            }
        }

        return Ok();
    }
}