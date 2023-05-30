// using System.Security.Claims;
// using backend_system_service.Repositories;
// using Core.Entities;
//
// namespace backend_system_service.Helper;
//
// public static class ObjectHelper<T> where T : class
// {
//     public static IEnumerable<T> GetAccessibleObject(ClaimsPrincipal user, IGenericRepository<T> repository)
//     {
//         var mail = user.Claims.FirstOrDefault(x => x.Type == ClaimTypes.Email)?.Value;
//         if(mail == null) return new List<T>();
//         var role = PermissionHelper.GetRole(mail);
//         if(role == null) return new List<T>();
//         
//         var type = typeof(T);
//         if (type == typeof(Tenant))
//         {
//             List<T> tenants = new();
//             var repo = repository as IGenericRepository<Tenant>;
//             if (role.IsSuperAdmin)
//             {
//                 var models = repo?.GetAll();
//                 tenants.AddRange(models as IEnumerable<T> ?? Array.Empty<T>());
//                 return tenants;
//             }
//             else
//             {
//                 var models = repo?.GetAllByCondition(x => x.Id == role.TenantId);
//                 tenants.AddRange(collection: models as IEnumerable<T> ?? Array.Empty<T>());
//                 return tenants;
//             }
//         }
//
//         if (type == typeof(Building))
//         {
//             List<T> buildings = new();
//             var repo = repository as IGenericRepository<Building>;
//             if (role.IsSuperAdmin)
//             {
//                 var models = repo?.GetAll();
//                 buildings.AddRange(models as IEnumerable<T> ?? Array.Empty<T>());
//                 return buildings;
//             }
//             else
//             {
//                 var models = repo?.GetAllByCondition(x => x.TenantId == role.TenantId);
//                 buildings.AddRange(models as IEnumerable<T> ?? Array.Empty<T>());
//                 return buildings;
//             }
//         }
//
//         if (type == typeof(BuildingUnit))
//         {
//             List<T> buildingUnits = new();
//             var repo = repository as IGenericRepository<BuildingUnit>;
//             if (role.IsSuperAdmin)
//             {
//                 var models = repo?.GetAll();
//                 buildingUnits.AddRange(models as IEnumerable<T> ?? Array.Empty<T>());
//                 return buildingUnits;
//             }
//
//             if (role.TenantId != Guid.Empty)
//             {
//                 var models = repo?.GetAllByCondition(x => x.Building.TenantId == role.TenantId);
//                 buildingUnits.AddRange(models as IEnumerable<T> ?? Array.Empty<T>());
//                 return buildingUnits;
//             }
//
//             var writeModels = repo?.GetAllByCondition(x => role.WriteBuildingUnitIds.Contains(x.Id));
//             var readModels = repo?.GetAllByCondition(x => role.ReadBuildingUnitIds.Contains(x.Id));
//             buildingUnits.AddRange(writeModels as IEnumerable<T> ?? Array.Empty<T>());
//             buildingUnits.AddRange(readModels as IEnumerable<T> ?? Array.Empty<T>());
//             return buildingUnits;
//         }
//
//         return new List<T>();
//     }
//
//
//     // private static RoleModel CheckUserRoles(ClaimsPrincipal user)
//     // {
//     //     var roles = user.FindAll(ClaimTypes.Role).Select(claim => claim.Value).ToList();
//     //     var model = new RoleModel
//     //     {
//     //         IsSuperAdmin = roles.Contains(SuperAdminRole),
//     //         IsTenantAdmin = roles.Any(role => role.Contains(TenantAdminRole))
//     //     };
//     //
//     //     if (model.IsTenantAdmin)
//     //     {
//     //         var role = roles.First(role => role.Contains(TenantAdminRole));
//     //         model.TenantId = Guid.Parse(role.Replace(TenantAdminRole, ""));
//     //     }
//     //
//     //     var writeAccessBuildingUnitIds = new List<string>();
//     //     var readAccessBuildingUnitIds = new List<string>();
//     //
//     //     foreach (var role in roles)
//     //     {
//     //         if (role.Contains(WriteAccessRole))
//     //         {
//     //             writeAccessBuildingUnitIds.Add(role.Replace(WriteAccessRole, ""));
//     //         }
//     //
//     //         if (role.Contains(ReadAccessRole))
//     //         {
//     //             readAccessBuildingUnitIds.Add(role.Replace(ReadAccessRole, ""));
//     //         }
//     //     }
//     //
//     //     model.WriteBuildingUnitIds = writeAccessBuildingUnitIds.Select(Guid.Parse).ToList();
//     //     model.ReadBuildingUnitIds = readAccessBuildingUnitIds.Select(Guid.Parse).ToList();
//     //
//     //     return model;
//     // }
// }