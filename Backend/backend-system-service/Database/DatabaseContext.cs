using Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace backend_system_service.Database;

public class DatabaseContext : DbContext
{
    public DatabaseContext(DbContextOptions<DatabaseContext> options)
        : base(options)
    {
    }

    public DbSet<Tenant> Tenants { get; set; } = null!;
    public DbSet<Building> Buildings { get; set; } = null!;
    public DbSet<Address> Addresses { get; set; } = null!;
    public DbSet<Room> Rooms { get; set; } = null!;
    public DbSet<BuildingUnit> BuildingUnits { get; set; } = null!;
    public DbSet<Gateway> Gateways { get; set; } = null!;
    public DbSet<SmokeDetector> SmokeDetectors { get; set; } = null!;
    public DbSet<SmokeDetectorAlarm> SmokeDetectorAlarms { get; set; } = null!;
    public DbSet<AutomationSetting> AutomationSettings { get; set; } = null!;
    public DbSet<NotificationSetting> NotificationSettings { get; set; } = null!;
    public DbSet<SmokeDetectorMaintenance> SmokeDetectorMaintenances { get; set; } = null!;
    public DbSet<SmokeDetectorModel> SmokeDetectorModels { get; set; } = null!;
    public DbSet<FireAlarm> FireAlarms { get; set; } = null!;
    public DbSet<ApiKey> ApiKeys { get; set; } = null!;
    public DbSet<MqttConnectionData> MqttConnectionData { get; set; } = null!;
    public DbSet<PreAlarmAutomationSetting> PreAlarmAutomationSettings { get; set; } = null!;

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        // It would be a good idea to move the connection string to user secrets
        // options.UseNpgsql(
        // "Host=localhost;Port=32768;Database=postgres;Username=postgres;Password=postgrespw");
        options.UseNpgsql(
            "Host=;Port=5433;Database=;Username=;Password=;");
    }
}