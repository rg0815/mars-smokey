using System.Collections.Concurrent;
using System.Security.Claims;
using Core.Entities;

namespace backend_system_service.Helper;

public static class PermissionHelper
{
    // load this list from grpc on startup
    // update this list when changing permissions via grpc
    public static readonly ConcurrentDictionary<string, UserModel> Roles = new();

    public static bool CheckPermission(UserModel role, Permission permission, object data)
    {
        return data switch
        {
            Tenant tenant => CheckPermissionInTenant(role, permission, tenant),
            Building building => CheckPermissionInBuilding(role, permission, building),
            Address address => CheckPermissionInBuilding(role, permission, address.Building),
            BuildingUnit buildingUnit => CheckPermissionInBuildingUnit(role, permission, buildingUnit),
            AutomationSetting automationSetting => CheckPermissionInBuildingUnit(role, permission,
                automationSetting.BuildingUnit),
            Room room => CheckPermissionInBuildingUnit(role, permission, room.BuildingUnit),
            Gateway gateway => CheckPermissionInBuildingUnit(role, permission, gateway.Room.BuildingUnit),
            SmokeDetector smokeDetector => CheckPermissionInBuildingUnit(role, permission,
                smokeDetector.Room.BuildingUnit),
            SmokeDetectorAlarm smokeDetectorAlarm => CheckPermissionInBuildingUnit(role, permission,
                smokeDetectorAlarm.SmokeDetector.Room.BuildingUnit),
            SmokeDetectorMaintenance smokeDetectorMaintenance => CheckPermissionInBuildingUnit(role, permission,
                smokeDetectorMaintenance.SmokeDetector.Room.BuildingUnit),
            NotificationSetting notificationSetting =>
                CheckPermissionInNotificationSetting(role.UserId, notificationSetting),

            _ => false
        };
    }

    private static bool CheckPermissionInNotificationSetting(Guid userId, NotificationSetting notificationSetting)
    {
        return notificationSetting.UserId == userId;
    }

    private static bool CheckPermissionInTenant(UserModel role, Permission permission, Tenant tenant)
    {
        switch (permission)
        {
            case Permission.Create:
                return false; // only automatic creation
            case Permission.Read:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == tenant.Id && role.IsTenantAdmin) return true;
                break;
            case Permission.Update:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == tenant.Id && role.IsTenantAdmin) return true;
                break;
            case Permission.Delete:
                if (role.IsSuperAdmin) return true;
                break;
            case Permission.ReadAll:
                if (role.IsSuperAdmin) return true;
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(permission), permission, null);
        }

        return false;
    }

    private static bool CheckPermissionInBuilding(UserModel role, Permission permission, Building building)
    {
        switch (permission)
        {
            case Permission.Create:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == building.TenantId && role.IsTenantAdmin) return true;
                break;
            case Permission.Read:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == building.TenantId && role.IsTenantAdmin) return true;
                break;
            case Permission.Update:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == building.TenantId && role.IsTenantAdmin) return true;
                break;
            case Permission.Delete:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == building.TenantId && role.IsTenantAdmin) return true;
                break;
            case Permission.ReadAll:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == building.TenantId && role.IsTenantAdmin) return true;
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(permission), permission, null);
        }

        return false;
    }

    private static bool CheckPermissionInBuildingUnit(UserModel role, Permission permission,
        BuildingUnit buildingUnit)
    {
        switch (permission)
        {
            case Permission.Create:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == buildingUnit.Building.TenantId && role.IsTenantAdmin) return true;
                break;
            case Permission.Read:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == buildingUnit.Building.TenantId && role.IsTenantAdmin) return true;
                if (role.WriteBuildingUnitIds.Contains(buildingUnit.Id)) return true;
                if (role.ReadBuildingUnitIds.Contains(buildingUnit.Id)) return true;
                break;
            case Permission.Update:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == buildingUnit.Building.TenantId && role.IsTenantAdmin) return true;
                if (role.WriteBuildingUnitIds.Contains(buildingUnit.Id)) return true;
                break;
            case Permission.Delete:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == buildingUnit.Building.TenantId && role.IsTenantAdmin) return true;
                break;
            case Permission.ReadAll:
                if (role.IsSuperAdmin) return true;
                if (role.TenantId == buildingUnit.Building.TenantId && role.IsTenantAdmin) return true;
                if (role.WriteBuildingUnitIds.Contains(buildingUnit.Id)) return true;
                if (role.ReadBuildingUnitIds.Contains(buildingUnit.Id)) return true;
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(permission), permission, null);
        }

        return false;
    }

    public static UserModel? GetRole(string userId)
    {
        return Roles.TryGetValue(userId, out var role) ? role : null;
    }

    public static UserModel? GetRole(ClaimsPrincipal user)
    {
        var userId = user.Claims.FirstOrDefault(c => c.Type == "Id")?.Value;
        return string.IsNullOrWhiteSpace(userId) ? null : GetRole(userId);
    }

    public static List<Guid> GetUsersInBuildingUnit(Guid buildingUnitId, Guid tenantId)
    {
        return (from role in Roles.Values
            where role.ReadBuildingUnitIds.Contains(buildingUnitId) ||
                  role.WriteBuildingUnitIds.Contains(buildingUnitId) || role.IsSuperAdmin ||
                  (role.IsTenantAdmin && role.TenantId == tenantId)
            select role.UserId).ToList();
    }
    
    public static List<UserModel> GetWriteUsersInBuildingUnit(Guid buildingUnitId, Guid tenantId)
    {
        return (from role in Roles.Values
            where role.WriteBuildingUnitIds.Contains(buildingUnitId) || role.IsSuperAdmin ||
                  (role.IsTenantAdmin && role.TenantId == tenantId)
            select role).ToList();
    }

    public static UserModel? GetRole(Guid userId)
    {
        return GetRole(userId.ToString());
    }
}

public enum Permission
{
    Create,
    Read,
    ReadAll,
    Update,
    Delete
}