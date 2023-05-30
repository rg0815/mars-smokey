using Newtonsoft.Json;

namespace Core.Entities
{
    public class SmokeDetectorMaintenance : BaseEntity
    {
        public DateTime Time { get; set; }
        public bool IsBatteryReplaced { get; set; }
        public bool IsDustCleaned { get; set; }
        public bool IsCleaned { get; set; }
        public bool IsTested { get; set; }
        public string Comment { get; set; }
        public string Signature { get; set; }
        public Guid SmokeDetectorId { get; set; }
         public SmokeDetector SmokeDetector { get; set; }
        public Guid UserId { get; set; }
    }
}