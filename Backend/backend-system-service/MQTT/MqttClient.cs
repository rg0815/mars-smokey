using System.Collections.Concurrent;
using backend_system_service.Helper;
using backend_system_service.Models.MQTT;
using Core.Entities;
using MQTTnet;
using MQTTnet.Client;
using MQTTnet.Extensions.ManagedClient;
using MQTTnet.Formatter;
using MQTTnet.Protocol;
using Newtonsoft.Json;
using NLog;

namespace backend_system_service.MQTT;

public static class MqttClient
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private static IManagedMqttClient _client = null!;
    public static ConcurrentDictionary<Guid, Tuple<Guid,UserModel>> RegisteredUpdateUsers = new();

    public static void Initialize()
    {
        var options = new ManagedMqttClientOptionsBuilder()
            .WithAutoReconnectDelay(TimeSpan.FromSeconds(10))
            .WithClientOptions(new MqttClientOptionsBuilder()
                .WithProtocolVersion(MqttProtocolVersion.V500)
                .WithClientId(Program.JwtSettings.BackendValidationKey)
                .WithTcpServer("localhost", 1883)
                .WithCredentials(Program.JwtSettings.BackendValidationKey, Program.JwtSettings.BackendValidationKey)
                .WithCleanSession()
                .Build())
            .Build();

        _client = new MqttFactory().CreateManagedMqttClient();

        _client.ConnectedAsync += ClientOnConnectedAsync;
        _client.DisconnectedAsync += ClientOnDisconnectedAsync;
        _client.ApplicationMessageReceivedAsync += ClientOnApplicationMessageReceivedAsync;
        _client.ConnectingFailedAsync += ClientOnConnectingFailedAsync;
        _client.SynchronizingSubscriptionsFailedAsync += ClientOnSynchronizingSubscriptionsFailedAsync;

        _client.StartAsync(options);

        // topic used for alarms
        Subscribe("ssds/up/#");
    }

    private static Task ClientOnSynchronizingSubscriptionsFailedAsync(ManagedProcessFailedEventArgs arg)
    {
        Logger.Error(arg.Exception);
        return Task.CompletedTask;
    }

    private static Task ClientOnConnectingFailedAsync(ConnectingFailedEventArgs arg)
    {
        Logger.Error(arg.Exception);
        return Task.CompletedTask;
    }

    private static Task ClientOnApplicationMessageReceivedAsync(MqttApplicationMessageReceivedEventArgs arg)
    {
        return IncomingMessageHandler.HandleMessage(arg);
    }

    private static Task ClientOnDisconnectedAsync(MqttClientDisconnectedEventArgs arg)
    {
        Logger.Error(arg.Exception);
        return Task.CompletedTask;
    }

    private static Task ClientOnConnectedAsync(MqttClientConnectedEventArgs arg)
    {
        Logger.Debug("Connected");
        return Task.CompletedTask;
    }

    private static void Subscribe(string topic)
    {
        _client.SubscribeAsync(topic, MqttQualityOfServiceLevel.AtLeastOnce);
    }

    public static void Unsubscribe(string topic)
    {
        _client.UnsubscribeAsync(topic);
    }

    public static async Task Publish(string topic, string message)
    {
        await _client.EnqueueAsync(topic, message, MqttQualityOfServiceLevel.AtLeastOnce);
    }

    public static void ForceShowUsernames(List<string> clientIds)
    {
        var payload = SerializePayload("info", "show");

        foreach (var clientId in clientIds)
        {
            var msg = new MqttMessage()
            {
                Action = MqttMessageAction.S_StartPairingGateway,
                ClientId = clientId,
                Payload = payload
            };

            var json = JsonConvert.SerializeObject(msg);
            Task.Run(() => Publish($"ssds/down/{clientId}", json));
        }

        var unused = new Timer(StopForceShowUsernamesCallback!, clientIds, TimeSpan.FromMinutes(5),
            Timeout.InfiniteTimeSpan);
    }

    private static void StopForceShowUsernamesCallback(object state)
    {
        if (state is List<string> clientIds)
        {
            StopForceShowUsernames(clientIds);
        }
    }

    public static void StopForceShowUsernames(List<string> clientIds)
    {
        var payload = SerializePayload("info", "hide");

        foreach (var clientId in clientIds)
        {
            var msg = new MqttMessage()
            {
                Action = MqttMessageAction.S_StopPairingGateway,
                ClientId = clientId,
                Payload = payload
            };

            var json = JsonConvert.SerializeObject(msg);
            Task.Run(() => Publish($"ssds/down/{clientId}", json));
        }
    }

    public static void PerformAlarm(string clientId, SmokeDetectorModel sdType, string rawCode)
    {
        var msg = new MqttMessage
        {
            ClientId = clientId,
            Action = MqttMessageAction.S_PerformAlarm,
            Payload = SerializePayload(new Dictionary<string, object>
            {
                { "pluginName", sdType.GetProtocolName() },
                { "rawCode", rawCode }
            })
        };

        Task.Run(() => Publish($"ssds/down/{clientId}", JsonConvert.SerializeObject(msg)));
    }

    public static void StopAlarm(string clientId, SmokeDetectorModel sdType, string rawCode)
    {
        var msg = new MqttMessage
        {
            ClientId = clientId,
            Action = MqttMessageAction.S_StopAlarm,
            Payload = SerializePayload(new Dictionary<string, object>
            {
                { "pluginName", sdType.GetProtocolName() },
                { "rawCode", rawCode }
            })
        };

        Task.Run(() => Publish($"ssds/down/{clientId}", JsonConvert.SerializeObject(msg)));
    }

    public static void StartPairing(string clientId)
    {
        var msg = new MqttMessage
        {
            ClientId = clientId,
            Action = MqttMessageAction.S_StartPairingSmokeDetector,
            Payload = SerializePayload("info", "startPairing")
        };

        Task.Run(() => Publish($"ssds/down/{clientId}", JsonConvert.SerializeObject(msg)));
    }

    public static void StopPairing(string clientId)
    {
        var msg = new MqttMessage
        {
            ClientId = clientId,
            Action = MqttMessageAction.S_StopPairingSmokeDetector,
            Payload = SerializePayload("info", "stopPairing")
        };

        Task.Run(() => Publish($"ssds/down/{clientId}", JsonConvert.SerializeObject(msg)));
    }

    public static void SendNewPairingData(string userId, string smokeDetectorId, Guid smokeDetectorProtocol)
    {
        var msg = new MqttMessage
        {
            ClientId = userId,
            Action = MqttMessageAction.SF_PairingSmokeDetectorInfo,
            Payload = SerializePayload(new Dictionary<string, object>
            {
                { "protocolId", smokeDetectorProtocol },
                { "smokeDetectorId", smokeDetectorId }
            })
        };
        
        Task.Run(() => Publish($"ssds/app/down/{userId}", JsonConvert.SerializeObject(msg)));
    }

    public static void SendAlarmInformation(Guid buildingUnitId, string text)
    {
        Task.Run(() => Publish($"ssds/alarm/{buildingUnitId}", text));
    }


    private static string SerializePayload(Dictionary<string, object> payload)
    {
        return JsonConvert.SerializeObject(payload);
    }

    public static string SerializePayload(string key, string value)
    {
        return SerializePayload(new Dictionary<string, object>
        {
            { key, value }
        });
    }
}