using backend_system_service.Database;
using backend_system_service.Helper;
using backend_system_service.Repositories;
using Core.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend_system_service.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StateController : ControllerBase
{
    private readonly IGenericRepository<BuildingUnit> _buildingUnitRepository;

    public StateController(IGenericRepository<BuildingUnit> buildingUnitRepository)
    {
        _buildingUnitRepository = buildingUnitRepository;
    }

    private SystemModel SystemModel => ApiKeyControllerHelper.CheckAuthentication(Request);

    [HttpGet]
    public ActionResult GetStateInBuildingUnit()
    {
        if (SystemModel.IsAuthenticated == false) return Forbid();

        var bUnit = _buildingUnitRepository.GetByCondition(x => x.Id == SystemModel.BuildingUnitId);
        if (bUnit == null)
        {
            return NotFound();
        }


        bool warning = false;
        foreach (var room in bUnit.Rooms)
        {
            foreach (var sd in room.SmokeDetectors)
            {
                if (sd.State == SmokeDetectorState.Warning)
                {
                    warning = true;
                }
            }
        }


        var model = new StateModel()
        {
            ActiveFireAlarm = bUnit.FireAlarms.FirstOrDefault(x => x.IsActive()),
            State = warning ? State.Warning :
                bUnit.FireAlarms.FirstOrDefault(x => x.IsActive()) != null ? State.AlarmActive : State.Ok,
            LastUpdate = DateTime.Now,
            BuildingUnitName = bUnit.Name,
            BuildingUnitId = bUnit.Id,
        };

        return Ok(model);
    }
}

public class StateModel
{
    public Guid BuildingUnitId { get; set; }
    public State State { get; set; }
    public DateTime LastUpdate { get; set; }
    public FireAlarm? ActiveFireAlarm { get; set; }
    public string BuildingUnitName { get; set; }
}

public enum State
{
    Ok,
    Warning,
    AlarmActive
}

public static class ApiKeyControllerHelper
{
    public static SystemModel CheckAuthentication(HttpRequest httpRequest)
    {
        var model = new SystemModel()
        {
            BuildingUnitId = Guid.Empty,
            IsAuthenticated = false
        };

        var header = httpRequest.Headers["X-API-KEY"];
        if (header.Count == 0)
        {
            return model;
        }

        var apiKeyString = header[0];
        if (string.IsNullOrEmpty(apiKeyString))
        {
            return model;
        }

        if (!Guid.TryParse(apiKeyString, out var apiKey))
        {
            return model;
        }

        var options = new DbContextOptions<DatabaseContext>();
        var buildingUnitRepository = new GenericRepository<BuildingUnit>(new DatabaseContext(options));


        var buildingUnit =
            buildingUnitRepository.GetByCondition(x => x.ApiKeys.FirstOrDefault(y => y.Key == apiKey) != null);
        if (buildingUnit == null)
        {
            return model;
        }

        model.BuildingUnitId = buildingUnit.Id;
        model.IsAuthenticated = true;
        return model;
    }
}