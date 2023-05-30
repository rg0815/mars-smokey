using backend_system_service.Database;
using backend_system_service.Repositories;
using Core.Entities;
using Microsoft.EntityFrameworkCore;
using NLog;

namespace backend_system_service.Services;

public static class ConnectionCheckService
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private static readonly ManualResetEvent WaitEvent = new(false);
    private static readonly List<Guid> ConnectionLost5Min = new();
    private static readonly List<Guid> ConnectionLost15Min = new();

    public static void StartThread()
    {
        var thread = new Thread(Loop);
        thread.Start();
    }
    
    private static void Loop()
    {
        while (true)
        {
            try
            {
                var options = new DbContextOptions<DatabaseContext>();
                var gatewayRepository = new GenericRepository<Gateway>(new DatabaseContext(options));
                var roomRepository = new GenericRepository<Room>(new DatabaseContext(options));
                var builingUnitRepository = new GenericRepository<BuildingUnit>(new DatabaseContext(options));
                var buildingRepository = new GenericRepository<Building>(new DatabaseContext(options));
                
                var gateways = gatewayRepository.GetAll();
                var connectionLost5Min =
                    gateways.Where(gateway => gateway.LastContact < DateTime.Now.AddMinutes(-5)).ToList();
                var connectionLost15Min =
                    gateways.Where(gateway => gateway.LastContact < DateTime.Now.AddMinutes(-15)).ToList();
                var gwBackOnline = gateways.Where(gateway =>
                    !ConnectionLost5Min.Contains(gateway.Id) && !ConnectionLost15Min.Contains(gateway.Id) &&
                    gateway.LastContact > DateTime.Now.AddMinutes(-5)).ToList();
            
                foreach (var gw in connectionLost5Min.Where(gw => !ConnectionLost5Min.Contains(gw.Id)))
                {
                    ConnectionLost5Min.Add(gw.Id);
                    Logger.Warn("Connection lost to gateway {0} for more than 5 minutes", gw.Id);

                    var room = roomRepository.GetById(gw.RoomId.GetValueOrDefault());
                    if (room == null)
                    {
                        Logger.Error("Failed to get room for gateway {0}", gw.Id);
                        continue;
                    }
                    
                    var buildingUnit = builingUnitRepository.GetById(room.BuildingUnitId);
                    if (buildingUnit == null)
                    {
                        Logger.Error("Failed to get building unit for gateway {0}", gw.Id);
                        continue;
                    }
                    
                    var building = buildingRepository.GetById(buildingUnit.BuildingId);
                    if (building == null)
                    {
                        Logger.Error("Failed to get building for gateway {0}", gw.Id);
                        continue;
                    }
                    
                    var res = NotificationServiceClient.SendGwOff5Minutes(gw.Name, room.BuildingUnitId,
                        building.TenantId);
                    if (!res)
                        Logger.Error("Failed to send notification to tenant {0} for gateway {1}",
                            gw.Room.BuildingUnit.Building.TenantId, gw.Id);
                }

                foreach (var gw in connectionLost15Min.Where(gw => !ConnectionLost15Min.Contains(gw.Id)))
                {
                    if (ConnectionLost5Min.Contains(gw.Id))
                    {
                        ConnectionLost5Min.Remove(gw.Id);
                    }
                    var room = roomRepository.GetById(gw.RoomId.GetValueOrDefault());
                    if (room == null)
                    {
                        Logger.Error("Failed to get room for gateway {0}", gw.Id);
                        continue;
                    }       var buildingUnit = builingUnitRepository.GetById(room.BuildingUnitId);
                    if (buildingUnit == null)
                    {
                        Logger.Error("Failed to get building unit for gateway {0}", gw.Id);
                        continue;
                    }
                    
                    var building = buildingRepository.GetById(buildingUnit.BuildingId);
                    if (building == null)
                    {
                        Logger.Error("Failed to get building for gateway {0}", gw.Id);
                        continue;
                    }

                    ConnectionLost15Min.Add(gw.Id);
                    Logger.Warn("Connection lost to gateway {0} for more than 15 minutes", gw.Id);
                    
                    var res = NotificationServiceClient.SendGwOff15Minutes(gw.Name, room.BuildingUnitId,
                        building.TenantId);
                    if (!res)
                        Logger.Error("Failed to send notification to tenant {0} for gateway {1}",
                            gw.Room.BuildingUnit.Building.TenantId, gw.Id);
                }

                foreach (var gw in gwBackOnline)
                {
                    if (ConnectionLost5Min.Contains(gw.Id))
                    {
                        ConnectionLost5Min.Remove(gw.Id);
                    }

                    if (ConnectionLost15Min.Contains(gw.Id))
                    {
                        ConnectionLost15Min.Remove(gw.Id);
                    }
                    var room = roomRepository.GetById(gw.RoomId.GetValueOrDefault());
                    if (room == null)
                    {
                        Logger.Error("Failed to get room for gateway {0}", gw.Id);
                        continue;
                    }       var buildingUnit = builingUnitRepository.GetById(room.BuildingUnitId);
                    if (buildingUnit == null)
                    {
                        Logger.Error("Failed to get building unit for gateway {0}", gw.Id);
                        continue;
                    }
                    
                    var building = buildingRepository.GetById(buildingUnit.BuildingId);
                    if (building == null)
                    {
                        Logger.Error("Failed to get building for gateway {0}", gw.Id);
                        continue;
                    }

                    Logger.Info("Connection to gateway {0} restored", gw.Id);

                    var res = NotificationServiceClient.SendGwBackOnline(gw.Name, room.BuildingUnitId,
                        building.TenantId);
                    if (!res)
                        Logger.Error("Failed to send notification to tenant {0} for gateway {1}",
                            gw.Room.BuildingUnit.Building.TenantId, gw.Id);
                }


                WaitEvent.WaitOne(TimeSpan.FromMinutes(1));
            }
            catch (Exception e)
            {
                Logger.Error(e);
                WaitEvent.WaitOne(TimeSpan.FromMinutes(1));
            }
        }
    }
}