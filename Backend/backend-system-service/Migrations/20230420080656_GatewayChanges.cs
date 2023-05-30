using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class GatewayChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Key",
                table: "Gateways",
                newName: "Username");

            migrationBuilder.AddColumn<Guid>(
                name: "ClientId",
                table: "Gateways",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "Password",
                table: "Gateways",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateTable(
                name: "GatewayRequests",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ClientId = table.Column<Guid>(type: "uuid", nullable: false),
                    Username = table.Column<Guid>(type: "uuid", nullable: false),
                    Password = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GatewayRequests", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "GatewayRequests");

            migrationBuilder.DropColumn(
                name: "ClientId",
                table: "Gateways");

            migrationBuilder.DropColumn(
                name: "Password",
                table: "Gateways");

            migrationBuilder.RenameColumn(
                name: "Username",
                table: "Gateways",
                newName: "Key");
        }
    }
}
