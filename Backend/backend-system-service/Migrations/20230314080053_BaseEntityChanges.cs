using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class BaseEntityChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AutomationSettings_BuildingUnits_BuildingUnitId",
                table: "AutomationSettings");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "Tenants");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "Tenants");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "SmokeDetectors");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "SmokeDetectors");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "SmokeDetectorMaintenances");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "SmokeDetectorMaintenances");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "SmokeDetectorAlarms");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "SmokeDetectorAlarms");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "Rooms");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "Rooms");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "NotificationSettings");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "Gateways");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "BuildingUnits");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "BuildingUnits");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "Buildings");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "Buildings");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "AutomationSettings");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "AutomationSettings");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "Addresses");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "Addresses");

            migrationBuilder.RenameColumn(
                name: "UpdatedBy",
                table: "NotificationSettings",
                newName: "UserId");

            migrationBuilder.RenameColumn(
                name: "UpdatedBy",
                table: "Gateways",
                newName: "Key");

            migrationBuilder.AlterColumn<Guid>(
                name: "BuildingUnitId",
                table: "AutomationSettings",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_AutomationSettings_BuildingUnits_BuildingUnitId",
                table: "AutomationSettings",
                column: "BuildingUnitId",
                principalTable: "BuildingUnits",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AutomationSettings_BuildingUnits_BuildingUnitId",
                table: "AutomationSettings");

            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "NotificationSettings",
                newName: "UpdatedBy");

            migrationBuilder.RenameColumn(
                name: "Key",
                table: "Gateways",
                newName: "UpdatedBy");

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "Tenants",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "Tenants",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "SmokeDetectorMaintenances",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "SmokeDetectorMaintenances",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "SmokeDetectorAlarms",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "SmokeDetectorAlarms",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "Rooms",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "Rooms",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "NotificationSettings",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "Gateways",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "BuildingUnits",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "BuildingUnits",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "Buildings",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "Buildings",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AlterColumn<Guid>(
                name: "BuildingUnitId",
                table: "AutomationSettings",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "AutomationSettings",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "AutomationSettings",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "Addresses",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "Addresses",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddForeignKey(
                name: "FK_AutomationSettings_BuildingUnits_BuildingUnitId",
                table: "AutomationSettings",
                column: "BuildingUnitId",
                principalTable: "BuildingUnits",
                principalColumn: "Id");
        }
    }
}
