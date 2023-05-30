using System.Linq.Expressions;
using backend_system_service.Database;
using Core.Entities;
using Microsoft.EntityFrameworkCore;
using NuGet.Protocol;

namespace backend_system_service.Repositories;

public class GenericRepository<T> : IGenericRepository<T> where T : BaseEntity
{
    private readonly DatabaseContext _context;
    private readonly DbSet<T> _dbSet;

    public GenericRepository(DatabaseContext context)
    {
        _context = context;
        _dbSet = _context.Set<T>();
    }

    public IEnumerable<T> GetAll()
    {
        if (typeof(T) == typeof(Tenant))
            return _dbSet.Include(t => (t as Tenant).Buildings.OrderBy(x => x.Name))
                .OrderBy(x => x.Name).ToList();


        if (typeof(T) == typeof(Building))
            return _dbSet
                .Include(b => (b as Building).BuildingUnits.OrderBy(x => x.Name))
                .Include(b => (b as Building).Address)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(BuildingUnit))
            return _dbSet
                .Include(bu => (bu as BuildingUnit).Rooms.OrderBy(x => x.Name))
                .Include(bu => (bu as BuildingUnit).AutomationSetting)
                .Include(b => (b as BuildingUnit).Building)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(Room))
            return _dbSet
                .Include(r => (r as Room).Gateways.OrderBy(x => x.Name))
                .Include(r => (r as Room).SmokeDetectors.OrderBy(x => x.Name))
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(Gateway))
            return _dbSet
                .Include(g => (g as Gateway).Room)
                .ThenInclude(r => r.BuildingUnit).OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(SmokeDetector))
            return _dbSet
                .Include(s => (s as SmokeDetector).Events.OrderBy(x => x.StartTime))
                .ThenInclude(e => e.FireAlarm)
                .Include(s => (s as SmokeDetector).Maintenances.OrderBy(x => x.Time)).OrderBy(x => x.Name)
                .Include(s => (s as SmokeDetector).SmokeDetectorModel)
                .Include(s => (s as SmokeDetector).Room)
                .ThenInclude(r => r.BuildingUnit)
                .ToList();

        if (typeof(T) == typeof(NotificationSetting))
            return _dbSet
                .Include(n => (n as NotificationSetting).Email)
                .Include(n => (n as NotificationSetting).PhoneNumber)
                .Include(n => (n as NotificationSetting).HttpNotifications).ThenInclude(h => h.Headers)
                .Include(n => (n as NotificationSetting).PushNotificationTokens)
                .Include(n => (n as NotificationSetting).SmsNumber)
                .OrderBy(x => x.Name)
                .ToList();

        if (typeof(T) == typeof(FireAlarm))
            return _dbSet
                .Include(f => (f as FireAlarm).BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .ThenInclude(b => b.Tenant)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.Room)
                .ThenInclude(r => r.BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.SmokeDetectorModel)
                .ToList();

        return _dbSet.OrderBy(x => x.Name).ToList();
    }

    public IEnumerable<T> GetAllByCondition(Expression<Func<T, bool>> predicate)
    {
        if (typeof(T) == typeof(Tenant))
            return _dbSet.Include(t => (t as Tenant).Buildings.OrderBy(x => x.Name)).Where(predicate)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(Building))
            return _dbSet
                .Include(b => (b as Building).BuildingUnits.OrderBy(x => x.Name))
                .Include(b => (b as Building).Address)
                .Where(predicate)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(BuildingUnit))
            return _dbSet
                .Include(bu => (bu as BuildingUnit).Rooms.OrderBy(x => x.Name))
                .Include(bu => (bu as BuildingUnit).AutomationSetting)
                .Include(b => (b as BuildingUnit).Building)
                .Where(predicate)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(Room))
            return _dbSet
                .Include(r => (r as Room).Gateways.OrderBy(x => x.Name))
                .Include(r => ((r as Room)!).SmokeDetectors.OrderBy(x => x.Name))
                .Where(predicate)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(Gateway))
            return _dbSet
                .Include(g => (g as Gateway).Room)
                .ThenInclude(r => r.BuildingUnit)
                .Where(predicate)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(SmokeDetector))
            return _dbSet
                .Include(s => (s as SmokeDetector).Events.OrderBy(x => x.StartTime))
                .ThenInclude(e => e.FireAlarm)
                .Include(s => (s as SmokeDetector).Maintenances.OrderBy(x => x.Time)).OrderBy(x => x.Name)
                .Include(s => (s as SmokeDetector).SmokeDetectorModel)
                .Include(s => (s as SmokeDetector).Room)
                .ThenInclude(r => r.BuildingUnit)
                .Where(predicate)
                .OrderBy(x => x.Name).ToList();

        if (typeof(T) == typeof(NotificationSetting))
            return _dbSet
                .Include(n => (n as NotificationSetting).Email)
                .Include(n => (n as NotificationSetting).PhoneNumber)
                .Include(n => (n as NotificationSetting).HttpNotifications).ThenInclude(h => h.Headers)
                .Include(n => (n as NotificationSetting).PushNotificationTokens)
                .Include(n => (n as NotificationSetting).SmsNumber)
                .Where(predicate)
                .OrderBy(x => x.Name)
                .ToList();

        if (typeof(T) == typeof(FireAlarm))
            return _dbSet
                .Include(f => (f as FireAlarm).BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .ThenInclude(b => b.Tenant)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.Room)
                .ThenInclude(r => r.BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.SmokeDetectorModel)
                .Where(predicate)
                .ToList();

        return _dbSet.Where(predicate).OrderBy(x => x.Name).ToList();
    }

    public T? GetByCondition(Expression<Func<T, bool>> predicate)
    {
        if (typeof(T) == typeof(Tenant))
            return _dbSet.Include(t => (t as Tenant).Buildings.OrderBy(x => x.Name))
                .OrderBy(x => x.Name).FirstOrDefault(predicate);

        if (typeof(T) == typeof(Building))
            return _dbSet
                .Include(b => (b as Building).BuildingUnits.OrderBy(x => x.Name))
                .Include(b => (b as Building).Address)
                .FirstOrDefault(predicate);

        if (typeof(T) == typeof(BuildingUnit))
            return _dbSet
                .Include(bu => (bu as BuildingUnit).Rooms.OrderBy(x => x.Name))
                .Include(bu => (bu as BuildingUnit).AutomationSetting)
                .Include(b => (b as BuildingUnit).Building)
                .FirstOrDefault(predicate);

        if (typeof(T) == typeof(Room))
            return _dbSet
                .Include(r => (r as Room).Gateways.OrderBy(x => x.Name))
                .Include(r => (r as Room).SmokeDetectors.OrderBy(x => x.Name))
                .FirstOrDefault(predicate);

        if (typeof(T) == typeof(Gateway))
            return _dbSet
                .Include(g => (g as Gateway).Room)
                .ThenInclude(r => r.BuildingUnit)
                .FirstOrDefault(predicate);

        if (typeof(T) == typeof(SmokeDetector))
            return _dbSet
                .Include(s => (s as SmokeDetector).Events.OrderBy(x => x.StartTime))
                .ThenInclude(e => e.FireAlarm)
                .Include(s => (s as SmokeDetector).Maintenances.OrderBy(x => x.Time)).OrderBy(x => x.Name)
                .Include(s => (s as SmokeDetector).SmokeDetectorModel)
                .Include(s => (s as SmokeDetector).Room)
                .ThenInclude(r => r.BuildingUnit)
                .FirstOrDefault(predicate);

        if (typeof(T) == typeof(NotificationSetting))
            return _dbSet
                .Include(n => (n as NotificationSetting).Email)
                .Include(n => (n as NotificationSetting).PhoneNumber)
                .Include(n => (n as NotificationSetting).HttpNotifications).ThenInclude(h => h.Headers)
                .Include(n => (n as NotificationSetting).PushNotificationTokens)
                .Include(n => (n as NotificationSetting).SmsNumber)
                .FirstOrDefault(predicate);

        if (typeof(T) == typeof(FireAlarm))
            return _dbSet
                .Include(f => (f as FireAlarm).BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .ThenInclude(b => b.Tenant)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.Room)
                .ThenInclude(r => r.BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.SmokeDetectorModel)
                .FirstOrDefault(predicate);


        return _dbSet.FirstOrDefault(predicate);
    }

    public T? GetById(Guid id)
    {
        if (typeof(T) == typeof(Tenant))
            return _dbSet.Include(t => (t as Tenant).Buildings.OrderBy(x => x.Name))
                .FirstOrDefault(t => t.Id == id);

        if (typeof(T) == typeof(Building))
            return _dbSet
                .Include(b => (b as Building).BuildingUnits.OrderBy(x => x.Name))
                .Include(b => (b as Building).Address)
                .FirstOrDefault(b => b.Id == id);

        if (typeof(T) == typeof(BuildingUnit))
            return _dbSet
                .Include(bu => (bu as BuildingUnit).Rooms.OrderBy(x => x.Name))
                .Include(bu => (bu as BuildingUnit).AutomationSetting)
                .Include(b => (b as BuildingUnit).Building)
                .FirstOrDefault(bu => bu.Id == id);

        if (typeof(T) == typeof(Room))
            return _dbSet
                .Include(r => (r as Room).Gateways.OrderBy(x => x.Name))
                .Include(r => (r as Room).SmokeDetectors.OrderBy(x => x.Name))
                .FirstOrDefault(r => r.Id == id);

        if (typeof(T) == typeof(Gateway))
            return _dbSet
                .Include(g => (g as Gateway).Room)
                .ThenInclude(r => r.BuildingUnit)
                .ThenInclude(b => b.Building)
                .ThenInclude(b => b.Tenant)
                .FirstOrDefault(g => g.Id == id);

        if (typeof(T) == typeof(SmokeDetector))
            return _dbSet
                .Include(s => (s as SmokeDetector).Events.OrderBy(x => x.StartTime))
                .ThenInclude(e => e.FireAlarm)
                .Include(s => (s as SmokeDetector).Maintenances.OrderBy(x => x.Time)).OrderBy(x => x.Name)
                .Include(s => (s as SmokeDetector).SmokeDetectorModel)
                .Include(s => (s as SmokeDetector).Room)
                .ThenInclude(r => r.BuildingUnit)
                .FirstOrDefault(s => s.Id == id);
        if (typeof(T) == typeof(NotificationSetting))
            return _dbSet
                .Include(n => (n as NotificationSetting).Email)
                .Include(n => (n as NotificationSetting).PhoneNumber)
                .Include(n => (n as NotificationSetting).HttpNotifications).ThenInclude(h => h.Headers)
                .Include(n => (n as NotificationSetting).PushNotificationTokens)
                .Include(n => (n as NotificationSetting).SmsNumber)
                .FirstOrDefault(n => n.Id == id);


        if (typeof(T) == typeof(FireAlarm))
            return _dbSet
                .Include(f => (f as FireAlarm).BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .ThenInclude(b => b.Tenant)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.Room)
                .ThenInclude(r => r.BuildingUnit)
                .ThenInclude(bu => bu.Building)
                .Include(f => (f as FireAlarm).AlarmedDetectors)
                .ThenInclude(ad => ad.SmokeDetector)
                .ThenInclude(sd => sd.SmokeDetectorModel)
                .FirstOrDefault(f => f.Id == id);


        return _dbSet.FirstOrDefault(x => x.Id == id);
    }

    public void Insert(T entity)
    {
        _dbSet.Add(entity);
        Save();
    }

    public void Update(T entity)
    {
        _dbSet.Attach(entity);
        _context.Entry(entity).State = EntityState.Modified;
        Save();
    }

    public void Delete(T entity)
    {
        _dbSet.Remove(entity);
        Save();
    }

    public void Delete(Guid id)
    {
        var entity = _dbSet.Find(id);
        if (entity != null) Delete(entity);
    }

    public void Save()
    {
        var entries = _context.ChangeTracker.Entries();
        foreach (var entry in entries)
        {
            if (entry.Entity is BaseEntity entity)
            {
                switch (entry.State)
                {
                    case EntityState.Added:
                        entity.CreatedAt = DateTime.Now.ToUniversalTime();
                        entity.UpdatedAt = DateTime.Now.ToUniversalTime();
                        break;
                    case EntityState.Modified:
                        entity.UpdatedAt = DateTime.Now.ToUniversalTime();
                        break;
                }
            }
        }

        _context.SaveChanges();
    }
}