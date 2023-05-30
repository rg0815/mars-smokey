using System.Globalization;
using System.Text;
using backend_system_service.Database;
using backend_system_service.Models;
using backend_system_service.Models.MQTT;
using backend_system_service.Repositories;
using backend_system_service.Services;
using Core.Entities;
using Microsoft.EntityFrameworkCore;
using MQTTnet.Client;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NLog;

namespace backend_system_service.MQTT;

public static class IncomingMessageHandler
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static Task HandleMessage(MqttApplicationMessageReceivedEventArgs arg)
    {
        try
        {
            var options = new DbContextOptions<DatabaseContext>();
            var smokeDetectorRepository = new GenericRepository<SmokeDetector>(new DatabaseContext(options));
            var smokeDetectorModelRepository = new GenericRepository<SmokeDetectorModel>(new DatabaseContext(options));
            var fireAlarmRepository = new GenericRepository<FireAlarm>(new DatabaseContext(options));
            var gatewayRepository = new GenericRepository<Gateway>(new DatabaseContext(options));
            var roomRepository = new GenericRepository<Room>(new DatabaseContext(options));
            var buildingUnitRepository = new GenericRepository<BuildingUnit>(new DatabaseContext(options));
            var buildingRepository = new GenericRepository<Building>(new DatabaseContext(options));

            if (arg.ApplicationMessage.Topic == null) return Task.CompletedTask;

            var topic = arg.ApplicationMessage.Topic;
            var payloadString = Encoding.UTF8.GetString(arg.ApplicationMessage.Payload);
            var message = JsonConvert.DeserializeObject<MqttMessage>(payloadString);

            Logger.Info(topic);
            Logger.Info(message);

            //extract client id from topic (ssds/up/f412fa74-d9b0-4389-9ba3-c571fc893406)
            var clientId = topic.Split("/")[2];

            if (!Guid.TryParse(clientId, out var clientGuid)) return Task.CompletedTask;
            var gateway = gatewayRepository.GetByCondition(x => x.ClientId == clientGuid);
            if (gateway?.RoomId == null) return Task.CompletedTask;
            var room = roomRepository.GetById((Guid)gateway.RoomId);
            if (room == null) return Task.CompletedTask;
            var buildingUnit = buildingUnitRepository.GetById(room.BuildingUnitId);
            if (buildingUnit == null) return Task.CompletedTask;
            if (message == null)
            {
                Logger.Error("Received invalid message");
                return Task.CompletedTask;
            }

            dynamic payload = JObject.Parse(message.Payload);


            switch (message.Action)
            {
                case MqttMessageAction.R_Connected:
                    Logger.Info("Gateway " + message.ClientId + " connected");
                    break;
                case MqttMessageAction.S_UsernameInfo:
                    break;
                case MqttMessageAction.R_Info:
                    break;
                case MqttMessageAction.R_Alert:
                    break;

                case MqttMessageAction.R_Alarm:
                    try
                    {
                        string rCode = payload.rawCode;

                        if (payload == null) return Task.CompletedTask;
                        var detector = smokeDetectorRepository.GetByCondition(x =>
                            x.Room != null && x.RawTransmissionData == rCode &&
                            x.Room.BuildingUnitId == buildingUnit.Id);
                        if (detector == null) return Task.CompletedTask;

                        if (detector.State == SmokeDetectorState.Alert) return Task.CompletedTask;

                        var smokeAlarm = new SmokeDetectorAlarm
                        {
                            SmokeDetectorId = detector.Id,
                            StartTime = DateTime.Now.ToUniversalTime()
                        };

                        detector.State = SmokeDetectorState.Alert;
                        smokeDetectorRepository.Update(detector);

                        var isNewAlarm = true;

                        FireAlarm? alarmInBuildingUnit;
                        alarmInBuildingUnit =
                            fireAlarmRepository.GetByCondition(x =>
                                x.BuildingUnitId == buildingUnit.Id && x.EndTime == DateTime.MinValue);
                        if (alarmInBuildingUnit != null)
                        {
                            alarmInBuildingUnit.IsProbableFalseAlarm = false;
                            alarmInBuildingUnit.AlarmedDetectors.Add(smokeAlarm);
                            fireAlarmRepository.Update(alarmInBuildingUnit);
                            isNewAlarm = false;
                        }
                        else
                        {
                            alarmInBuildingUnit = new FireAlarm
                            {
                                BuildingUnitId = buildingUnit.Id,
                                StartTime = DateTime.Now.ToUniversalTime(),
                                AlarmedDetectors = new List<SmokeDetectorAlarm> { smokeAlarm },
                                IsProbableFalseAlarm = true,
                            };

                            fireAlarmRepository.Insert(alarmInBuildingUnit);
                        }

                        var evacuate = fireAlarmRepository.GetAllByCondition(x =>
                                x.EndTime == DateTime.MinValue && x.BuildingUnit.BuildingId == buildingUnit.BuildingId)
                            .Count() >= 2;


                        alarmInBuildingUnit = fireAlarmRepository.GetById(alarmInBuildingUnit.Id);

                        var activeSmokeDetectors = new List<string>();
                        foreach (var sd in alarmInBuildingUnit.AlarmedDetectors)
                            activeSmokeDetectors.Add(sd.SmokeDetector.Room.BuildingUnit.Building.Name + " " +
                                                     sd.SmokeDetector.Room.BuildingUnit.Name + " " +
                                                     sd.SmokeDetector.Room.Name + " " + sd.SmokeDetector.Name);

                        var alarmModel = new AlarmHandlerModel
                        {
                            SmokeDetectors = activeSmokeDetectors,
                            Location = buildingUnit.Building.Name + " - " + buildingUnit.Name + " - " + room.Name,
                            Room = room,
                            BuildingId = buildingUnit.BuildingId,
                            BuildingUnit = buildingUnit,
                            HandlePreAlarm = buildingUnit.SendPreAlarm,
                            IsProbableFalseAlarm = isNewAlarm,
                            EvacuateBuilding = evacuate,
                            IsExpanding = !isNewAlarm,
                        };

                        var alarmThread = new Thread(() => AlarmService.HandleAlarm(alarmModel));
                        alarmThread.Start();

                        if (isNewAlarm && buildingUnit.SendPreAlarm)
                        {
                            //start timer of 1 minute
                            var unused = new Timer(CheckAlarmHandledCallback!, Tuple.Create(alarmInBuildingUnit, room),
                                TimeSpan.FromMinutes(3),
                                Timeout.InfiniteTimeSpan);
                            return Task.CompletedTask;
                        }

                        var gwList = gatewayRepository.GetAllByCondition(x => x.Room.BuildingUnitId == buildingUnit.Id);
                        var sdList = smokeDetectorRepository.GetAllByCondition(x =>
                            x.State != SmokeDetectorState.Alert &&
                            x.Room.BuildingUnitId == buildingUnit.Id &&
                            x.SmokeDetectorModel.SupportsRemoteAlarm);

                        foreach (var gw in gwList)
                        {
                            foreach (var sd in sdList)
                            {
                                if (detector.Id == sd.Id)
                                {
                                    MqttClient.StopAlarm(gw.ClientId.ToString(), sd.SmokeDetectorModel,
                                        sd.RawTransmissionData);
                                }

                                MqttClient.PerformAlarm(gw.ClientId.ToString(),
                                    sd.SmokeDetectorModel,
                                    sd.RawTransmissionData);
                            }
                        }

                        if (evacuate)
                        {
                            //also alarm all other buildingUnits in the building
                            var buildingUnits = buildingUnitRepository.GetAllByCondition(x =>
                                x.BuildingId == buildingUnit.BuildingId && x.Id != buildingUnit.Id);

                            foreach (var bUnit in buildingUnits)
                            {
                                var buildingGws = gatewayRepository.GetAllByCondition(x =>
                                    x.Room.BuildingUnitId == bUnit.Id);
                                var buildingSds = smokeDetectorRepository.GetAllByCondition(x =>
                                    x.State != SmokeDetectorState.Alert &&
                                    x.Room.BuildingUnitId == bUnit.Id &&
                                    x.SmokeDetectorModel.SupportsRemoteAlarm);

                                foreach (var gw in buildingGws)
                                {
                                    foreach (var sd in buildingSds)
                                    {
                                        MqttClient.PerformAlarm(gw.ClientId.ToString(),
                                            sd.SmokeDetectorModel,
                                            sd.RawTransmissionData);
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Logger.Error(e);
                    }

                    break;
                case MqttMessageAction.S_StartPairingGateway:
                    break;
                case MqttMessageAction.S_StopPairingGateway:
                    break;
                case MqttMessageAction.S_StartPairingSmokeDetector:
                    break;
                case MqttMessageAction.S_StopPairingSmokeDetector:
                    break;
                case MqttMessageAction.R_PairingSmokeDetectorInfo:

                    string modelString = payload.model;
                    string rawCode = payload.rawCode;


                    if (payload == null) return Task.CompletedTask;
                    var model = smokeDetectorModelRepository.GetByCondition(x => x.Description == modelString);
                    if (model == null) return Task.CompletedTask;

                    var building = buildingRepository.GetById(buildingUnit.BuildingId);
                    if (building == null) return Task.CompletedTask;

                    var isExisting = false;

                    SmokeDetector? existingSmokeDetector = null;

                    foreach (var s in buildingUnit.Rooms.Select(unitRoom => smokeDetectorRepository.GetByCondition(
                                     x => x.RawTransmissionData == rawCode
                                          && x.RoomId == unitRoom.Id
                                          && x.SmokeDetectorModel.SmokeDetectorProtocol == model.SmokeDetectorProtocol))
                                 .Where(s => s != null))
                    {
                        existingSmokeDetector = s;
                        isExisting = true;
                        break;
                    }

                    if (isExisting && existingSmokeDetector?.Name == "NEW SMOKE DETECTOR" &&
                        existingSmokeDetector.Description == "NEW SMOKE DETECTOR")
                    {
                        var regUsers = MqttClient.RegisteredUpdateUsers.Where(x => x.Value.Item1 == gateway.Id);
                        foreach (var regUser in regUsers)
                        {
                            MqttClient.SendNewPairingData(regUser.Key.ToString(),
                                existingSmokeDetector.Id.ToString(), existingSmokeDetector.SmokeDetectorModelId);
                        }

                        return Task.CompletedTask;
                    }


                    var smokeDetector = new SmokeDetector
                    {
                        Name = "NEW SMOKE DETECTOR",
                        Description = "NEW SMOKE DETECTOR",
                        Events = new List<SmokeDetectorAlarm>(),
                        Maintenances = new List<SmokeDetectorMaintenance>(),
                        LastBatteryReplacement = DateTime.MinValue.ToUniversalTime(),
                        LastMaintenance = DateTime.MinValue.ToUniversalTime(),
                        BatteryLevel = 100,
                        BatteryLow = false,
                        State = SmokeDetectorState.Normal,
                        RoomId = room.Id,
                        RawTransmissionData = payload.rawCode,
                        SmokeDetectorModelId = model.Id
                    };

                    smokeDetectorRepository.Insert(smokeDetector);
                    var regUsersNew = MqttClient.RegisteredUpdateUsers.Where(x => x.Value.Item1 == gateway.Id);
                    foreach (var regUser in regUsersNew)
                    {
                        MqttClient.SendNewPairingData(regUser.Key.ToString(),
                            smokeDetector.Id.ToString(), smokeDetector.SmokeDetectorModelId);
                    }

                    break;

                case MqttMessageAction.S_GatewayInitialized:
                    break;
                case MqttMessageAction.S_PerformAlarm:
                    break;
                case MqttMessageAction.S_StopAlarm:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
        catch (Exception e)
        {
            Logger.Error(e);
        }


        return Task.CompletedTask;
    }

    private static void CheckAlarmHandledCallback(object state)
    {
        var oldAlarm = ((Tuple<FireAlarm, Room>)state).Item1;
        var room = ((Tuple<FireAlarm, Room>)state).Item2;

        var options = new DbContextOptions<DatabaseContext>();
        var fireAlarmRepository = new GenericRepository<FireAlarm>(new DatabaseContext(options));

        var alarm = fireAlarmRepository.GetById(oldAlarm.Id);
        if (alarm == null) return;

        if (alarm.EndTime > DateTime.MinValue.ToUniversalTime()) return;

        var buildingUnit = alarm.BuildingUnit;
        var alarmModel = new AlarmHandlerModel
        {
            Location = buildingUnit.Building.Name + " - " + buildingUnit.Name + " - " + room.Name,
            BuildingId = buildingUnit.BuildingId,
            BuildingUnit = buildingUnit,
            HandlePreAlarm = buildingUnit.SendPreAlarm,
            IsProbableFalseAlarm = false,
            EvacuateBuilding = false,
            IsExpanding = false,
        };

        var alarmThread = new Thread(() => AlarmService.HandleAlarm(alarmModel));
        alarmThread.Start();
    }
}