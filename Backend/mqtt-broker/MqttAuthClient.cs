using Grpc.Core;
using Grpc.Net.Client;
using NLog;
using ssds_mqtt;

namespace mqtt_broker;

public static class MqttAuthClient
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static bool OnSubscribed(string clientId, string topic)
    {
        try
        {
            var client = new MqttService.MqttServiceClient(GrpcChannel.ForAddress("http://localhost:84"));
            var res = client.OnSubscribedAction(new OnSubscribedRequest()
            {
                ClientId = clientId,
                Topic = topic
            }, GetHeaders());

            if(!res.Result)
                Logger.Error($"Error while subscribing: {res.Reason}");
            
            return res is {Result: true};
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    public static bool AuthorizeUser(string clientId, string topic, string access)
    {
        try
        {
            var client = new MqttService.MqttServiceClient(GrpcChannel.ForAddress("http://localhost:84"));
            var res = client.CheckAuthorization(new AuthorizationRequest
            {
                ClientId = clientId,
                Access = access,
                Topic = topic
            }, GetHeaders());

            return res is {Result: true};
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    public static bool AuthenticateUser(string clientId, string username, string password)
    {
        try
        {
            var client = new MqttService.MqttServiceClient(GrpcChannel.ForAddress("http://localhost:84"));
            var res = client.CheckAuthentication(new AuthenticationRequest
            {
                ClientId = clientId,
                Username = username,
                Password = password
            }, GetHeaders());

            return res is {Result: true};
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    private static Metadata GetHeaders()
    {
        var metadata = new Metadata();
        var key = Program.JwtSettings.BackendValidationKey;
        if (key == null) throw new Exception("No key found");
        metadata.Add("x-custom-backend-auth", key);
        return metadata;
    }
}