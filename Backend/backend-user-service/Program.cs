using System.Text;
using backend_user_service.Repositories;
using backend_user_service.Repository;
using backend_user_service.Service;
using Core.Entities;
using Core.Settings;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using NLog;
using NLog.Web;

namespace backend_user_service;

internal class Program
{
    public static JwtSettings? JwtSettings { get; private set; }

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
                    policyBuilder.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader();
                });
            });

            builder.Services.AddGrpc(options => { options.EnableDetailedErrors = true; });
            builder.Services.AddGrpcReflection();

// DB
            builder.Services.AddDbContext<UsersContext>();
            builder.Services.AddScoped(typeof(IUserInvitationRepository), typeof(UserInvitationRepository));
            builder.Services.AddScoped(typeof(UserRepository));
// Auth
            builder.Services.AddIdentityCore<AppUser>(options =>
                {
                    options.SignIn.RequireConfirmedAccount = false;
                    options.User.RequireUniqueEmail = true;
                    options.Password.RequireDigit = false;
                    options.Password.RequiredLength = 6;
                    options.Password.RequireNonAlphanumeric = false;
                    options.Password.RequireUppercase = false;
                    options.Password.RequireLowercase = false;
                })
                // .AddRoles<IdentityRole>()
                .AddEntityFrameworkStores<UsersContext>();

            #region Auth

            builder.Services.AddScoped<TokenService, TokenService>();

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(options =>
            {
                options.SaveToken = true;
                options.TokenValidationParameters = new TokenValidationParameters()
                {
                    ClockSkew = TimeSpan.Zero,
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = builder.Configuration["Jwt:Issuer"],
                    ValidAudience = builder.Configuration["Jwt:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? string.Empty)
                    )
                };
            });

            #endregion


// Controllers
            builder.Services.AddControllers().AddNewtonsoftJson(options =>
                {
                    options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Serialize;
                    options.SerializerSettings.NullValueHandling = Newtonsoft.Json.NullValueHandling.Ignore;
                }
            );

            #region Swagger

            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen(option =>
            {
                option.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "SSDS - USER SERVICE API", Version = "v1", Contact = new OpenApiContact()
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

            #endregion


            var app = builder.Build();

            using (var scope = app.Services.CreateScope())
            {
                var services = scope.ServiceProvider;

                var context = services.GetRequiredService<UsersContext>();
                context.Database.Migrate();
            }
            if (app.Environment.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

// Configure the HTTP request pipeline.
            app.UseSwagger(
                c => { c.RouteTemplate = "api/user/swagger/{documentName}/swagger.json"; }
            );
            app.UseSwaggerUI(
                c =>
                {
                    c.SwaggerEndpoint("/api/user/swagger/v1/swagger.json", "SSDS - USER SERVICE API");
                    c.RoutePrefix = "api/user/swagger";
                }
            );

            app.UseCors("CorsPolicy");
            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();

            app.MapGrpcService<UserServiceServer>();
            app.MapGrpcReflectionService();

            UserUpdateManager.Initialize();

            app.Run();
        }
        catch (Exception ex)
        {
            logger.Error(ex);
        }
    }
}