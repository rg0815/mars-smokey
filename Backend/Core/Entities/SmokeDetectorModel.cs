
using Newtonsoft.Json;

namespace Core.Entities;

public class SmokeDetectorModel : BaseEntity
{
    public CommunicationType CommunicationType { get; set; }
    public bool SupportsRemoteAlarm { get; set; }
    public bool SupportsBatteryAlarm { get; set; }
    public int BatteryReplacementInterval { get; set; }
    public int MaintenanceInterval { get; set; }
    public SmokeDetectorProtocol SmokeDetectorProtocol { get; set; }

    public ICollection<SmokeDetector>? SmokeDetectors { get; set; }

    public SmokeDetectorModel()
    {
    }

    public SmokeDetectorModel(string? manufacturer, string? model, CommunicationType communicationType,
        int batteryReplacementInterval, int maintenanceInterval, SmokeDetectorProtocol smokeDetectorProtocol)
    {
        Name = manufacturer ?? "";
        Description = model ?? throw new ArgumentNullException(nameof(model));
        CommunicationType = communicationType;
        BatteryReplacementInterval = batteryReplacementInterval;
        MaintenanceInterval = maintenanceInterval;
        SmokeDetectorProtocol = smokeDetectorProtocol;
    }
    
    public string GetProtocolName()
    {
        return SmokeDetectorProtocol switch
        {
            SmokeDetectorProtocol.Rm175Rf => "RM175RF",
            SmokeDetectorProtocol.Fa22Rf => "FA22RF",
            SmokeDetectorProtocol.Gira => "Gira",
            SmokeDetectorProtocol.Cavius => "Cavius",
            SmokeDetectorProtocol.Zigbee => "Zigbee",
            _ => throw new ArgumentOutOfRangeException()
        };
    }
}

public enum CommunicationType
{
    Mhz433,
    Mhz868,
    Gira,
    Cavius,
    Zigbee
}

public enum SmokeDetectorProtocol
{
    // DO NOT CHANGE THE ORDER OF THESE ENUMS, IT WILL BREAK THE DATABASE
    // ADD NEW ONES AT THE END, AND ADD THE NEW MODEL TO THE INITMODELS METHOD

    Rm175Rf = 1,
    Fa22Rf = 2,
    Gira=3,
    Cavius=4,
    Zigbee=5


    //TODO ADD MORE MODELS
}

