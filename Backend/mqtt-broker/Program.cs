using System.Net;
using Core.Settings;
using Microsoft.AspNetCore.HttpOverrides;
using mqtt_broker;
using MQTTnet.AspNetCore;
using NLog;
using NLog.Web;


internal class Program
{
    public static JwtSettings JwtSettings { get; private set; }

    public static void Main(string[] args)
    {
        var logger = LogManager.Setup().LoadConfigurationFromAppSettings().GetCurrentClassLogger();
        var builder = WebApplication.CreateBuilder(args);
        builder.Logging.ClearProviders();
        builder.Logging.AddConsole();
       
        builder.Configuration.AddJsonFile("appsettings.json", false, true);
        builder.Configuration.AddJsonFile("appsettings.Development.json", true, true);
        builder.Configuration.AddEnvironmentVariables();
        
        builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("Jwt"));
        var jwtSettings = builder.Configuration.GetSection("Jwt").Get<JwtSettings>();
        if (jwtSettings == null)
        {
            logger.Fatal("JWT settings are not configured or invalid");
            throw new InvalidOperationException("JWT settings are not configured or invalid");
        }

        JwtSettings = jwtSettings;



// Configure services
        builder.Services.AddCors(options =>
        {
            options.AddPolicy("CorsPolicy", policyBuilder =>
            {
                policyBuilder.AllowAnyOrigin()
                    .AllowAnyMethod()
                    .AllowAnyHeader();
            });
        });

        builder.Services.AddGrpc();
        builder.Services.AddGrpcReflection();
        
        builder.Services
            .AddHostedMqttServer()
            .AddMqttConnectionHandler()
            .AddConnections();

// Configure Kestrel server to listen on TCP port 1883 and WebSocket port 5000
        builder.WebHost.ConfigureKestrel(options =>
        {
            options.ListenAnyIP(1883, listenOptions => { listenOptions.UseMqtt(); });
            options.ListenAnyIP(5000 );
        }); 

        var app = builder.Build();

        if (app.Environment.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }
        
        app.UseForwardedHeaders(new ForwardedHeadersOptions
        {
            KnownProxies = { IPAddress.Parse(""), IPAddress.Parse("") },
            ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
        });

        app.UseCors("CorsPolicy");
        app.UseRouting();

        app.MapConnectionHandler<MqttConnectionHandler>(
            "",
            httpConnectionDispatcherOptions =>
                httpConnectionDispatcherOptions.WebSockets.SubProtocolSelector =
                    protocolList => protocolList.FirstOrDefault() ?? string.Empty);

        app.UseMqttServer(
            server =>
            {
                /*
         * Attach event handlers etc. if required.
         */
                server.ClientConnectedAsync += MqttHelper.OnClientConnected;
                server.ValidatingConnectionAsync += MqttHelper.ValidateConnection;
                server.ClientDisconnectedAsync += MqttHelper.OnClientDisconnected;
                server.ClientSubscribedTopicAsync += MqttHelper.OnClientSubscribed;
                server.InterceptingPublishAsync += MqttHelper.InterceptPublish;
                server.InterceptingSubscriptionAsync += MqttHelper.InterceptSubscribe;
            });

        app.Run();
    }
    
    
    
}