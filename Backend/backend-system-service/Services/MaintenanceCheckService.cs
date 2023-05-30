using backend_system_service.Database;
using backend_system_service.Repositories;
using Core.Entities;
using Microsoft.EntityFrameworkCore;
using NLog;

namespace backend_system_service.Services;

public static class MaintenanceCheckService
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private static readonly ManualResetEvent WaitEvent = new ManualResetEvent(false);

    public static void StartThread()
    {
        var thread = new Thread(Loop);
        thread.Start();
    }

    private static void Loop()
    {
        var options = new DbContextOptions<DatabaseContext>();
        var smokeDetectorRepository = new GenericRepository<SmokeDetector>(new DatabaseContext(options));
        while (true)
        {
            if (DateTime.Now.Hour != 0 || DateTime.Now.Minute > 1)
            {
                WaitEvent.WaitOne(TimeSpan.FromMinutes(1));
                continue;
            }
            
            try
            {
                var smokeDetectors7Days = smokeDetectorRepository.GetAllByCondition(
                    sd => (sd.LastMaintenance.AddDays(sd.SmokeDetectorModel.MaintenanceInterval) - DateTime.Now).Days ==
                          7);

                var smokeDetectors1Day = smokeDetectorRepository.GetAllByCondition(
                    sd => (sd.LastMaintenance.AddDays(sd.SmokeDetectorModel.MaintenanceInterval) - DateTime.Now).Days ==
                          1);

                var batteryReplace = smokeDetectorRepository.GetAllByCondition(
                    sd => (sd.LastBatteryReplacement.AddDays(sd.SmokeDetectorModel.BatteryReplacementInterval) - DateTime.Now).Days ==
                          7);
                
                foreach (var sd in smokeDetectors7Days)
                {
                    NotificationServiceClient.SendMaintenance7Days(sd.Name, sd.Room.BuildingUnitId,
                        sd.Room.BuildingUnit.Building.TenantId);
                }
                
                foreach (var sd in smokeDetectors1Day)
                {
                    NotificationServiceClient.SendMaintenance7Days(sd.Name, sd.Room.BuildingUnitId,
                        sd.Room.BuildingUnit.Building.TenantId);
                }
                
                foreach (var sd in batteryReplace)
                {
                    NotificationServiceClient.SendBatteryReplace(sd.Name, sd.Room.BuildingUnitId,
                        sd.Room.BuildingUnit.Building.TenantId);
                }
            }
            catch (Exception e)
            {
                Logger.Error(e);
            }
        }
    }
}