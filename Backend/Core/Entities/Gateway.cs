using Newtonsoft.Json;

namespace Core.Entities;

public class Gateway : BaseEntity
{
    public Guid Username { get; set; }
    public Guid ClientId { get; set; }
    public Guid Password{ get; set; }
    public bool IsInitialized { get; set; }
    public DateTime LastContact { get; set; }
    public Guid? RoomId { get; set; }
    public Room? Room { get; set; }
}