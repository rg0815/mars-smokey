using Core.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace backend_user_service;

public class UsersContext : IdentityDbContext<AppUser, IdentityRole, string>
{
    public UsersContext(DbContextOptions<UsersContext> options)
        : base(options)
    {
    }

    public DbSet<UserInvitation> UserInvitations { get; set; } = null!;

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        // It would be a good idea to move the connection string to user secrets
        // options.UseNpgsql(
        // "Host=localhost;Port=32768;Database=postgres;Username=postgres;Password=postgrespw");
        options.UseNpgsql(
            "Host=;Port=5432;Database=postgres;Username=;Password=");
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
    }
}