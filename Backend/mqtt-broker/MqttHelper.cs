using MQTTnet.Server;
using NLog;

namespace mqtt_broker;

public static class MqttHelper
{
    public static Task OnClientConnected(ClientConnectedEventArgs eventArgs)
    {
        var logger = LogManager.GetCurrentClassLogger();
        logger.Info($"Client '{eventArgs.ClientId}' connected.");
        return Task.CompletedTask;
    }

    public static Task OnClientSubscribed(ClientSubscribedTopicEventArgs arg)
    {
        var logger = LogManager.GetCurrentClassLogger();
        logger.Info($"Client '{arg.ClientId}' successfully subscribed to topic '{arg.TopicFilter.Topic}'.");
        var res = MqttAuthClient.OnSubscribed(arg.ClientId, arg.TopicFilter.Topic);
    return Task.CompletedTask;
    }

    public static Task ValidateConnection(ValidatingConnectionEventArgs eventArgs)
    {
        var logger = LogManager.GetCurrentClassLogger();
        var res = MqttAuthClient.AuthenticateUser(eventArgs.ClientId, eventArgs.UserName, eventArgs.Password);
        if (res)
        {
            logger.Info($"Client '{eventArgs.ClientId}' wants to connect. Accepting!");
            eventArgs.ReasonCode = MQTTnet.Protocol.MqttConnectReasonCode.Success;
        }
        else
        {
            logger.Info($"Client '{eventArgs.ClientId}' wants to connect. Rejecting!");
            eventArgs.ReasonCode = MQTTnet.Protocol.MqttConnectReasonCode.BadUserNameOrPassword;
        }

        return Task.CompletedTask;
    }

    public static Task OnClientDisconnected(ClientDisconnectedEventArgs arg)
    {
        var logger = LogManager.GetCurrentClassLogger();
        logger.Info($"Client '{arg.ClientId}' disconnected. Reason: {arg.DisconnectType}");
        return Task.CompletedTask;
    }

    public static Task InterceptPublish(InterceptingPublishEventArgs arg)
    {
        var logger = LogManager.GetCurrentClassLogger();
        var res = MqttAuthClient.AuthorizeUser(arg.ClientId, arg.ApplicationMessage.Topic, "publish");

        if (!res)
        {
            logger.Info(
                $"Client '{arg.ClientId}' wants to publish to topic '{arg.ApplicationMessage.Topic}'. Not authorized!");
            arg.Response.ReasonCode = MQTTnet.Protocol.MqttPubAckReasonCode.NotAuthorized;
        }
        else
        {
            logger.Info(
                $"Client '{arg.ClientId}' wants to publish to topic '{arg.ApplicationMessage.Topic}'. Authorized!");
            arg.Response.ReasonCode = MQTTnet.Protocol.MqttPubAckReasonCode.Success;
        }

        return Task.CompletedTask;
    }

    public static Task InterceptSubscribe(InterceptingSubscriptionEventArgs arg)
    {
        var logger = LogManager.GetCurrentClassLogger();
        var res = MqttAuthClient.AuthorizeUser(arg.ClientId, arg.TopicFilter.Topic, "subscribe");

        if (!res)
        {
            logger.Info(
                $"Client '{arg.ClientId}' wants to subscribe to topic '{arg.TopicFilter.Topic}'. Not authorized!");
            arg.Response.ReasonCode = MQTTnet.Protocol.MqttSubscribeReasonCode.NotAuthorized;
        }
        else
        {
            logger.Info($"Client '{arg.ClientId}' wants to subscribe to topic '{arg.TopicFilter.Topic}'. Authorized!");
            arg.Response.ReasonCode = MQTTnet.Protocol.MqttSubscribeReasonCode.GrantedQoS1;
        }

        return Task.CompletedTask;
    }
}