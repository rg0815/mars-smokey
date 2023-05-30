using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class SmokeDetectorChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SmokeDetectorModelType",
                table: "SmokeDetectors");

            migrationBuilder.AddColumn<string>(
                name: "RawTransmissionData",
                table: "SmokeDetectors",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "SmokeDetectorModelId",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateTable(
                name: "SmokeDetectorModel",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CommunicationType = table.Column<int>(type: "integer", nullable: false),
                    BatteryReplacementInterval = table.Column<int>(type: "integer", nullable: false),
                    MaintenanceInterval = table.Column<int>(type: "integer", nullable: false),
                    SmokeDetectorProtocol = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SmokeDetectorModel", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SmokeDetectors_SmokeDetectorModelId",
                table: "SmokeDetectors",
                column: "SmokeDetectorModelId");

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModel_SmokeDetectorModelId",
                table: "SmokeDetectors",
                column: "SmokeDetectorModelId",
                principalTable: "SmokeDetectorModel",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModel_SmokeDetectorModelId",
                table: "SmokeDetectors");

            migrationBuilder.DropTable(
                name: "SmokeDetectorModel");

            migrationBuilder.DropIndex(
                name: "IX_SmokeDetectors_SmokeDetectorModelId",
                table: "SmokeDetectors");

            migrationBuilder.DropColumn(
                name: "RawTransmissionData",
                table: "SmokeDetectors");

            migrationBuilder.DropColumn(
                name: "SmokeDetectorModelId",
                table: "SmokeDetectors");

            migrationBuilder.AddColumn<int>(
                name: "SmokeDetectorModelType",
                table: "SmokeDetectors",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }
    }
}
