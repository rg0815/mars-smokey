using backend_system_service.Helper;
using backend_system_service.Models.MQTT;
using backend_system_service.MQTT;
using backend_system_service.Repositories;
using Core.Entities;
using Grpc.Core;
using Newtonsoft.Json;
using ssds_mqtt;

namespace backend_system_service.Services;

public class MqttAuthService : MqttService.MqttServiceBase
{
    private readonly ILogger<MqttAuthService> _logger;
    private readonly IGenericRepository<Gateway> _gatewayRepository;
    private readonly IGenericRepository<BuildingUnit> _buildingUnitRepository;
    private readonly IGenericRepository<MqttConnectionData> _mqttConnectionDataRepository;


    public MqttAuthService(ILogger<MqttAuthService> logger, IGenericRepository<Gateway> gatewayRepository, IGenericRepository<BuildingUnit> buildingUnitRepository, IGenericRepository<MqttConnectionData> mqttConnectionDataRepository)
    {
        _logger = logger;
        _gatewayRepository = gatewayRepository;
        _buildingUnitRepository = buildingUnitRepository;
        _mqttConnectionDataRepository = mqttConnectionDataRepository;
    }

    public override Task<BasicResponse> OnSubscribedAction(OnSubscribedRequest request, ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(x => x.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Result = false,
                Reason = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Result = false,
                Reason = "No authorization header"
            });
        }

        if (CheckIfBackend(request))
        {
            return Allow();
        }
        
        if(request.Topic.StartsWith("ssds/app/down/"))
        {
            return Allow();
        }

        if (!Guid.TryParse(request.ClientId, out var clientId))
        {
            return Deny("Invalid client id");
        }

        var existingGw = _gatewayRepository.GetByCondition(x => x.ClientId == clientId);
        if (existingGw == null)
        {
            return Deny("Gateway not found");
        }

        if (existingGw.IsInitialized)
        {
            var initMsg = new MqttMessage()
            {
                ClientId = clientId.ToString(),
                Action = MqttMessageAction.S_GatewayInitialized,
                Payload = MqttClient.SerializePayload("info", "GW is initialized")
            };

            var initJson = JsonConvert.SerializeObject(initMsg);
            Task.Run(() => MQTT.MqttClient.Publish("ssds/down/" + clientId, initJson));

            return Allow();
        }

        var msg = new MqttMessage()
        {
            ClientId = clientId.ToString(),
            Action = MqttMessageAction.S_UsernameInfo,
            Payload = MqttClient.SerializePayload("username", existingGw.Username.ToString())
        };


        var json = JsonConvert.SerializeObject(msg);
        Task.Run(() => MQTT.MqttClient.Publish("ssds/register/" + clientId, json));

        return Allow();
    }

    private static bool CheckIfBackend(OnSubscribedRequest request)
    {
        return request.ClientId.StartsWith(Program.JwtSettings.BackendValidationKey);
    }

    public override Task<BasicResponse> CheckAuthentication(AuthenticationRequest request, ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(x => x.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Result = false,
                Reason = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Result = false,
                Reason = "No authorization header"
            });
        }

        if (CheckIfBackend(request))
        {
            return Allow();
        }

        if (request.ClientId.StartsWith("app_"))
        {
            var userId = request.ClientId.Replace("app_", "");
            var role = PermissionHelper.GetRole(userId);
            if (role == null) return Deny("User not found");

            var res = TokenService.ValidateToken(request.Password);
            if (userId != res.Item1) return Deny("Invalid token");
            return request.Username != res.Item2 ? Deny("Invalid username") : Allow();
        }
        
        if (!Guid.TryParse(request.Password, out var password))
        {
            return Deny("Invalid password");
        }
        
        if (!Guid.TryParse(request.ClientId, out var clientId))
        {
            if (!Guid.TryParse(request.Username, out var mqttUsername))
            {
                return Deny("Invalid username");
            }
            
            var connectionData = _mqttConnectionDataRepository.GetByCondition(x => x.Username == mqttUsername);
            if(connectionData == null) return Deny("Connection data not found");

            if (!PasswordHasher.VerifyPassword(request.Username, connectionData.PasswordHash))
            {
                return Deny("Invalid password");
            }

            connectionData.ClientId = request.ClientId;
            return Allow();

        }

  

        var existingGw = _gatewayRepository.GetByCondition(x => x.ClientId == clientId);
        if (existingGw == null && request.Username == "NEW-GATEWAY")
        {
            return HandleNewGateway(clientId, password);
        }

        if (existingGw == null)
        {
            return Deny("Gateway not found");
        }

        if (!existingGw.IsInitialized && request.Username == "NEW-GATEWAY")
        {
            return Allow();
        }

        if (!Guid.TryParse(request.Username, out var username))
        {
            return Deny("Invalid username");
        }

        return HandleExistingGateway(existingGw, clientId, password, username);
    }

    public override Task<BasicResponse> CheckAuthorization(AuthorizationRequest request, ServerCallContext context)
    {
        var headers = context.RequestHeaders;
        var authHeader = headers.FirstOrDefault(x => x.Key == "x-custom-backend-auth");
        if (authHeader == null)
        {
            context.Status = new Status(StatusCode.PermissionDenied, "No authorization header");
            return Task.FromResult(new BasicResponse
            {
                Result = false,
                Reason = "No authorization header"
            });
        }

        if (Program.JwtSettings == null) throw new InvalidOperationException("JwtSettings is null");
        if (!authHeader.Value.Equals(Program.JwtSettings.BackendValidationKey))
        {
            context.Status = new Status(StatusCode.PermissionDenied, "Invalid");
            return Task.FromResult(new BasicResponse
            {
                Result = false,
                Reason = "No authorization header"
            });
        }

        if (CheckIfBackend(request))
        {
            return Allow();
        }

        if (request.ClientId.StartsWith("app_"))
        {
            if (request.Topic.StartsWith("ssds/app/down/"))
            {
                var appUserId = request.ClientId.Replace("app_", "");
                var appRole = PermissionHelper.GetRole(appUserId);
                if (appRole == null) return Deny("User not found");
                
                var topicUserId = request.Topic.Replace("ssds/app/down/", "");
                if(topicUserId != appUserId) return Deny("Invalid topic");

                return Allow();

            }

            return Deny("Invalid topic");
        }
        
        if (!Guid.TryParse(request.ClientId, out var clientId))
        {
            var mqttConnection = _mqttConnectionDataRepository.GetByCondition(x => x.ClientId == request.ClientId);
            if(mqttConnection == null) return Deny("Connection data not found");

            if (request.Topic == "ssds/up/iot/" + mqttConnection.BuildingUnitId && request.Access == "publish")
            {
                return Allow();
            }
            
            if(request.Topic == "ssds/down/iot/" + mqttConnection.BuildingUnitId && request.Access == "subscribe")
            {
                return Allow();
            }
            
            return Deny("Invalid topic");
        }

        _logger.LogInformation("Authorization | Topic: " + request.Topic + " | ClientId: " + clientId + " | Action: " +
                               request.Access);

        var existingGw = _gatewayRepository.GetByCondition(x => x.ClientId == clientId);
        if (existingGw == null)
        {
            return Deny("Gateway not found");
        }

        if (request.Access == "subscribe")
        {
            return HandleSubscribeRequest(request, existingGw, clientId);
        }
        else if (request.Access == "publish")
        {
            return HandlePublishRequest(request, existingGw);
        }

        return Deny("Invalid action");
    }


    private Task<BasicResponse> HandleExistingGateway(Gateway existingGw, Guid clientId, Guid password,
        Guid username)
    {
        if (existingGw.Username != username || existingGw.Password != password || existingGw.ClientId != clientId)
        {
            return Deny("Invalid username or password or client id");
        }

        existingGw.LastContact = DateTime.Now.ToUniversalTime();
        _gatewayRepository.Update(existingGw);
        _gatewayRepository.Save();

        return Allow();
    }

    private Task<BasicResponse> HandleNewGateway(Guid clientId, Guid password)
    {
        var gateway = new Gateway()
        {
            ClientId = clientId,
            Username = Guid.NewGuid(),
            Password = password,
            Name = clientId.ToString(),
            Room = null,
            RoomId = null,
            IsInitialized = false,
            LastContact = DateTime.Now.ToUniversalTime()
        };

        _gatewayRepository.Insert(gateway);
        _gatewayRepository.Save();

        return Allow();
    }

    private static bool CheckIfBackend(AuthenticationRequest request)
    {
        return request.Username == Program.JwtSettings.BackendValidationKey &&
               request.Password == Program.JwtSettings.BackendValidationKey &&
               request.ClientId.StartsWith(Program.JwtSettings.BackendValidationKey);
    }

    private static bool CheckIfBackend(AuthorizationRequest request)
    {
        return request.ClientId.StartsWith(Program.JwtSettings.BackendValidationKey);
    }

    private Task<BasicResponse> Allow(string info = "")
    {
        Console.BackgroundColor = ConsoleColor.DarkGreen;
        Console.ForegroundColor = ConsoleColor.White;
        _logger.LogInformation("Authorization - Allow - " + info);
        Console.ResetColor();

        return Task.FromResult(new BasicResponse
        {
            Result = true,
            Reason = info
        });
    }

    private Task<BasicResponse> Deny(string info)
    {
        Console.BackgroundColor = ConsoleColor.DarkRed;
        Console.ForegroundColor = ConsoleColor.White;
        _logger.LogInformation("Authorization - Deny - " + info);
        Console.ResetColor();

        return Task.FromResult(new BasicResponse
        {
            Result = false,
            Reason = info
        });
    }

    private Task<BasicResponse> HandlePublishRequest(AuthorizationRequest request, Gateway existingGw)
    {
        if (!existingGw.IsInitialized && request.Topic == "ssds/register")
        {
            return Allow();
        }

        if (request.Topic.StartsWith("ssds/up/" + existingGw.ClientId))
        {
            return Allow();
        }

        return Deny("Topic not allowed");
    }

    private Task<BasicResponse> HandleSubscribeRequest(AuthorizationRequest request, Gateway existingGw,
        Guid clientId)
    {
        if (request.Topic.StartsWith("ssds/register"))
        {
            var topicClientId = request.Topic.Split("/")[2];
            if (existingGw.IsInitialized || topicClientId != clientId.ToString())
            {
                return Deny("Gateway already initialized");
            }


            return Allow();
        }

        if (request.Topic.StartsWith("ssds/down/" + clientId))
        {
            return Allow();
        }

        return Deny("Topic not allowed");
    }

    private bool CheckIfBackend(MqttAuthorizationRequest request)
    {
        var res = request.Username == Program.JwtSettings.BackendValidationKey &&
                  request.ClientId == Program.JwtSettings.BackendValidationKey;

        _logger.LogInformation("CheckIfBackend: {Res}", res);
        return res;
    }
}