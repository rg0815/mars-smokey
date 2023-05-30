namespace backend_system_service.Models;

public class AddSmokeDetectorMaintenanceRequest
{
    public bool IsBatteryReplaced { get; set; }
    public bool IsDustCleaned { get; set; }
    public bool IsCleaned { get; set; }
    public bool IsTested { get; set; }
    public string Comment { get; set; }
    public string Signature { get; set; }
}