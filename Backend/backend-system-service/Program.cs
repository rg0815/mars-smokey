using System.Text;
using backend_system_service.Database;
using backend_system_service.MQTT;
using backend_system_service.Repositories;
using backend_system_service.Services;
using Core.Settings;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using NLog;
using NLog.Web;

namespace backend_system_service;

public static class Program
{
    public static JwtSettings JwtSettings { get; private set; }

    public static void Main(string[] args)
    {
        var logger = LogManager.Setup().LoadConfigurationFromAppSettings().GetCurrentClassLogger();
        try
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Logging.ClearProviders();
            builder.Host.UseNLog();

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

            builder.Services.AddCors(options =>
            {
                options.AddPolicy("CorsPolicy", policyBuilder =>
                {
                    policyBuilder
                        .AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader()
                        .SetIsOriginAllowed((host) => true);
                });
            });

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(options =>
            {
                options.SaveToken = false;
                options.TokenValidationParameters = new TokenValidationParameters()
                {
                    ClockSkew = TimeSpan.Zero,
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = jwtSettings.Issuer,
                    ValidAudience = jwtSettings.Audience,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(jwtSettings.Key)
                    )
                };
            });

            builder.Services.AddSignalR(o => o.EnableDetailedErrors = true);
            // builder.Services.AddSingleton<IUserIdProvider, EmailBasedUserIdProvider>();

// DB
            builder.Services.AddDbContext<DatabaseContext>();
            builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
// Add services to the container.

            builder.Services.AddControllers().AddNewtonsoftJson(options =>
                {
                    options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
                    options.SerializerSettings.NullValueHandling = Newtonsoft.Json.NullValueHandling.Ignore;
                }
            );
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen(option =>
            {
                option.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "SSDS - SYSTEM SERVICE API", Version = "v1", Contact = new OpenApiContact()
                    {
                        Name = "mars engineering GmbH",
                        Email = "roman.glorim@mars-engineering.de",
                        Url = new Uri("https://mars-engineering.de")
                    }
                });

                option.AddSecurityDefinition(JwtBearerDefaults.AuthenticationScheme, new OpenApiSecurityScheme
                {
                    In = ParameterLocation.Header,
                    Description = "JWT Authorization header using the Bearer scheme (Example: 'Bearer 12345abcdef')",
                    Name = "Authorization",
                    Type = SecuritySchemeType.Http,
                    BearerFormat = "JWT",
                    Scheme = JwtBearerDefaults.AuthenticationScheme
                });

                option.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = JwtBearerDefaults.AuthenticationScheme
                            }
                        },
                        Array.Empty<string>()
                    }
                });
            });


            builder.Services.AddGrpc();
            builder.Services.AddGrpcReflection();

            var app = builder.Build();

            using (var scope = app.Services.CreateScope())
            {
                var services = scope.ServiceProvider;

                var context = services.GetRequiredService<DatabaseContext>();
                context.Database.Migrate();
            }

            app.UseSwagger(
                c=> { c.RouteTemplate = "api/system/swagger/{documentName}/swagger.json"; }
                );
            app.UseSwaggerUI(
                c =>
                {
                    c.SwaggerEndpoint("/api/system/swagger/v1/swagger.json", "SSDS - USER SERVICE API");
                    c.RoutePrefix = "api/system/swagger";
                }
            );

// Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }


            app.UseCors("CorsPolicy");
            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();

            app.MapGrpcReflectionService();
            app.MapGrpcService<MqttAuthService>();

            MqttClient.Initialize();
            UserServiceClient.StartThread();
            ConnectionCheckService.StartThread();
            MaintenanceCheckService.StartThread();
            
            
            app.Run();
        }
        catch (Exception ex)
        {
            logger.Error(ex);
        }
    }
}