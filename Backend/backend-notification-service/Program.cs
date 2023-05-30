using System.Text;
using backend_notification_service.Notifier;
using backend_notification_service.Services;
using backend_notification_service.Settings;
using Core.Settings;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using NLog;
using NLog.Web;

namespace backend_notification_service;

public static class Program
{
    public static NotifierSettings NotifierSettings { get; private set; } = null!;
    public static JwtSettings? JwtSettings { get; set; }
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static void Main(string[] args)
    {
        try
        {
            var builder = WebApplication.CreateBuilder(args);
            SetupLogging(ref builder);
            SetupConfiguration(ref builder);
            SetupCors(ref builder);
            // SetupAuthentication(ref builder);
            SetupGrpc(ref builder);
            var app = builder.Build();

            if (app.Environment.IsDevelopment())
            {
                // app.UseSwagger();
                // app.UseSwaggerUI(c =>
                // {
                //     c.SwaggerEndpoint("/swagger/v1/swagger.json", "Backend Notification Service API v1");
                // });
                app.UseDeveloperExceptionPage();
            }
            

            app.UseCors("CorsPolicy");
            // app.UseAuthentication();
            // app.UseAuthorization();

            // app.MapControllers();
            app.MapGrpcReflectionService();
            app.MapGrpcService<MailServiceServer>();
            app.MapGrpcService<NotificationServiceServer>();

            Logger.Info("Application started");
            NotificationManager.Initialize();

            app.Run();
        }
        catch (Exception ex)
        {
            Logger.Error(ex);
        }
    }

    private static void SetupGrpc(ref WebApplicationBuilder builder)
    {
        builder.Services.AddGrpc();
        // builder.Services.AddGrpc().AddJsonTranscoding();
        builder.Services.AddGrpcReflection();
// Add services to the container.

        // builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        // builder.Services.AddEndpointsApiExplorer();
        // builder.Services.AddGrpcSwagger();
        // builder.Services.AddSwaggerGen(option =>
        // {
        //     option.SwaggerDoc("v1", new OpenApiInfo
        //     {
        //         Title = "SSDS - NOTIFICATION SERVICE API", Version = "v1", Contact = new OpenApiContact()
        //         {
        //             Name = "mars engineering GmbH",
        //             Email = "roman.glorim@mars-engineering.de",
        //             Url = new Uri("https://mars-engineering.de")
        //         }
        //     });
        //     option.AddSecurityDefinition(JwtBearerDefaults.AuthenticationScheme, new OpenApiSecurityScheme
        //     {
        //         In = ParameterLocation.Header,
        //         Description = "JWT Authorization header using the Bearer scheme (Example: 'Bearer 12345abcdef')",
        //         Name = "Authorization",
        //         Type = SecuritySchemeType.Http,
        //         BearerFormat = "JWT",
        //         Scheme = JwtBearerDefaults.AuthenticationScheme
        //     });
        //
        //     option.AddSecurityRequirement(new OpenApiSecurityRequirement
        //     {
        //         {
        //             new OpenApiSecurityScheme
        //             {
        //                 Reference = new OpenApiReference
        //                 {
        //                     Type = ReferenceType.SecurityScheme,
        //                     Id = JwtBearerDefaults.AuthenticationScheme
        //                 }
        //             },
        //             Array.Empty<string>()
        //         }
        //     });
        // });
    }

    private static void SetupCors(ref WebApplicationBuilder builder)
    {
        builder.Services.AddCors(options =>
        {
            options.AddPolicy("CorsPolicy", corsPolicyBuilder =>
            {
                corsPolicyBuilder.AllowAnyOrigin()
                    .AllowAnyMethod()
                    .AllowAnyHeader();
            });
        });
    }

    private static void SetupAuthentication(ref WebApplicationBuilder builder)
    {
        builder.Services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        }).AddJwtBearer(options =>
        {
            options.SaveToken = false;

            if (JwtSettings == null)
            {
                Logger.Error("JwtSettings is null");
                return;
            }

            options.TokenValidationParameters = new TokenValidationParameters()
            {
                ClockSkew = TimeSpan.Zero,
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = JwtSettings.Issuer,
                ValidAudience = JwtSettings.Audience,
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(JwtSettings.Key)
                )
            };
        });

        builder.Services.AddAuthorization();
    }

    private static void SetupConfiguration(ref WebApplicationBuilder builder)
    {
        builder.Configuration.AddJsonFile("appsettings.json", false, true);
        builder.Configuration.AddJsonFile("appsettings.Development.json", true, true);
        builder.Configuration.AddEnvironmentVariables();
        builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("Jwt"));
        var jwtSettings = builder.Configuration.GetSection("Jwt").Get<JwtSettings>();
        if (jwtSettings == null)
        {
            Logger.Fatal("JWT settings are not configured or invalid");
            throw new InvalidOperationException("JWT settings are not configured or invalid");
        }

        builder.Services.Configure<NotifierSettings>(builder.Configuration.GetSection("Notifier"));
        var notifierSettings = builder.Configuration.GetSection("Notifier").Get<NotifierSettings>();
        if (notifierSettings == null)
        {
            Logger.Fatal("Notifier settings are not configured or invalid");
            throw new InvalidOperationException("Notifier settings are not configured or invalid");
        }

        NotifierSettings = notifierSettings;
        JwtSettings = jwtSettings;
    }

    private static void SetupLogging(ref WebApplicationBuilder builder)
    {
        builder.Logging.ClearProviders();
        builder.Host.UseNLog();
    }
}