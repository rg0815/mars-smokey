using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class MultipleChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_HttpNotification_NotificationSettings_NotificationSettingId",
                table: "HttpNotification");

            migrationBuilder.DropIndex(
                name: "IX_AutomationSettings_BuildingUnitId",
                table: "AutomationSettings");

            migrationBuilder.DropColumn(
                name: "EndTime",
                table: "SmokeDetectorAlarms");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "NotificationSettings");

            migrationBuilder.DropColumn(
                name: "PhoneNumber",
                table: "NotificationSettings");

            migrationBuilder.DropColumn(
                name: "SMSNumber",
                table: "NotificationSettings");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Tenants",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectors",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectorModels",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<bool>(
                name: "SupportsBatteryAlarm",
                table: "SmokeDetectorModels",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "SupportsRemoteAlarm",
                table: "SmokeDetectorModels",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectorMaintenances",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<string>(
                name: "Signature",
                table: "SmokeDetectorMaintenances",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectorAlarms",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<Guid>(
                name: "FireAlarmId",
                table: "SmokeDetectorAlarms",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Rooms",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "PushNotificationToken",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "NotificationSettings",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<Guid>(
                name: "NotificationSettingId",
                table: "HttpNotification",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "HttpNotification",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<Guid>(
                name: "AutomationSettingId",
                table: "HttpNotification",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "PreAlarmAutomationSettingId",
                table: "HttpNotification",
                type: "uuid",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Header",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Gateways",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "BuildingUnits",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<string>(
                name: "MqttText",
                table: "BuildingUnits",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "SendMqttInfo",
                table: "BuildingUnits",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "SendPreAlarm",
                table: "BuildingUnits",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Buildings",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "AutomationSettings",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Addresses",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.CreateTable(
                name: "ApiKeys",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Key = table.Column<Guid>(type: "uuid", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    LastUsed = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    BuildingUnitId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApiKeys", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ApiKeys_BuildingUnits_BuildingUnitId",
                        column: x => x.BuildingUnitId,
                        principalTable: "BuildingUnits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FireAlarms",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    StartTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    EndTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsProbableFalseAlarm = table.Column<bool>(type: "boolean", nullable: false),
                    WasFalseAlarm = table.Column<bool>(type: "boolean", nullable: false),
                    BuildingUnitId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FireAlarms", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FireAlarms_BuildingUnits_BuildingUnitId",
                        column: x => x.BuildingUnitId,
                        principalTable: "BuildingUnits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MqttConnectionData",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Username = table.Column<Guid>(type: "uuid", nullable: false),
                    PasswordHash = table.Column<string>(type: "text", nullable: false),
                    BuildingUnitId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MqttConnectionData", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MqttConnectionData_BuildingUnits_BuildingUnitId",
                        column: x => x.BuildingUnitId,
                        principalTable: "BuildingUnits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PreAlarmAutomationSettings",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BuildingUnitId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PreAlarmAutomationSettings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PreAlarmAutomationSettings_BuildingUnits_BuildingUnitId",
                        column: x => x.BuildingUnitId,
                        principalTable: "BuildingUnits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserEmailNotification",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    NotificationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserEmailNotification", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserEmailNotification_NotificationSettings_NotificationSett~",
                        column: x => x.NotificationSettingId,
                        principalTable: "NotificationSettings",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "AutomationEmailNotification",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    AutomationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    Subject = table.Column<string>(type: "text", nullable: true),
                    Text = table.Column<string>(type: "text", nullable: true),
                    PreAlarmAutomationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AutomationEmailNotification", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AutomationEmailNotification_AutomationSettings_AutomationSe~",
                        column: x => x.AutomationSettingId,
                        principalTable: "AutomationSettings",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_AutomationEmailNotification_PreAlarmAutomationSettings_PreA~",
                        column: x => x.PreAlarmAutomationSettingId,
                        principalTable: "PreAlarmAutomationSettings",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "PhoneCallNotification",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    PhoneNumber = table.Column<string>(type: "text", nullable: true),
                    NotificationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    AutomationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    PreAlarmAutomationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PhoneCallNotification", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PhoneCallNotification_AutomationSettings_AutomationSettingId",
                        column: x => x.AutomationSettingId,
                        principalTable: "AutomationSettings",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_PhoneCallNotification_NotificationSettings_NotificationSett~",
                        column: x => x.NotificationSettingId,
                        principalTable: "NotificationSettings",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_PhoneCallNotification_PreAlarmAutomationSettings_PreAlarmAu~",
                        column: x => x.PreAlarmAutomationSettingId,
                        principalTable: "PreAlarmAutomationSettings",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SmsNotification",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    PhoneNumber = table.Column<string>(type: "text", nullable: true),
                    NotificationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    AutomationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    Discriminator = table.Column<string>(type: "character varying(34)", maxLength: 34, nullable: false),
                    Text = table.Column<string>(type: "text", nullable: true),
                    PreAlarmAutomationSettingId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "text", nullable: true),
                    Description = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SmsNotification", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SmsNotification_AutomationSettings_AutomationSettingId",
                        column: x => x.AutomationSettingId,
                        principalTable: "AutomationSettings",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SmsNotification_NotificationSettings_NotificationSettingId",
                        column: x => x.NotificationSettingId,
                        principalTable: "NotificationSettings",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SmsNotification_PreAlarmAutomationSettings_PreAlarmAutomati~",
                        column: x => x.PreAlarmAutomationSettingId,
                        principalTable: "PreAlarmAutomationSettings",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_SmokeDetectorAlarms_FireAlarmId",
                table: "SmokeDetectorAlarms",
                column: "FireAlarmId");

            migrationBuilder.CreateIndex(
                name: "IX_HttpNotification_AutomationSettingId",
                table: "HttpNotification",
                column: "AutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_HttpNotification_PreAlarmAutomationSettingId",
                table: "HttpNotification",
                column: "PreAlarmAutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_AutomationSettings_BuildingUnitId",
                table: "AutomationSettings",
                column: "BuildingUnitId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ApiKeys_BuildingUnitId",
                table: "ApiKeys",
                column: "BuildingUnitId");

            migrationBuilder.CreateIndex(
                name: "IX_AutomationEmailNotification_AutomationSettingId",
                table: "AutomationEmailNotification",
                column: "AutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_AutomationEmailNotification_PreAlarmAutomationSettingId",
                table: "AutomationEmailNotification",
                column: "PreAlarmAutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_FireAlarms_BuildingUnitId",
                table: "FireAlarms",
                column: "BuildingUnitId");

            migrationBuilder.CreateIndex(
                name: "IX_MqttConnectionData_BuildingUnitId",
                table: "MqttConnectionData",
                column: "BuildingUnitId");

            migrationBuilder.CreateIndex(
                name: "IX_PhoneCallNotification_AutomationSettingId",
                table: "PhoneCallNotification",
                column: "AutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_PhoneCallNotification_NotificationSettingId",
                table: "PhoneCallNotification",
                column: "NotificationSettingId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PhoneCallNotification_PreAlarmAutomationSettingId",
                table: "PhoneCallNotification",
                column: "PreAlarmAutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_PreAlarmAutomationSettings_BuildingUnitId",
                table: "PreAlarmAutomationSettings",
                column: "BuildingUnitId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SmsNotification_AutomationSettingId",
                table: "SmsNotification",
                column: "AutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_SmsNotification_NotificationSettingId",
                table: "SmsNotification",
                column: "NotificationSettingId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SmsNotification_PreAlarmAutomationSettingId",
                table: "SmsNotification",
                column: "PreAlarmAutomationSettingId");

            migrationBuilder.CreateIndex(
                name: "IX_UserEmailNotification_NotificationSettingId",
                table: "UserEmailNotification",
                column: "NotificationSettingId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_HttpNotification_AutomationSettings_AutomationSettingId",
                table: "HttpNotification",
                column: "AutomationSettingId",
                principalTable: "AutomationSettings",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_HttpNotification_NotificationSettings_NotificationSettingId",
                table: "HttpNotification",
                column: "NotificationSettingId",
                principalTable: "NotificationSettings",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_HttpNotification_PreAlarmAutomationSettings_PreAlarmAutomat~",
                table: "HttpNotification",
                column: "PreAlarmAutomationSettingId",
                principalTable: "PreAlarmAutomationSettings",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectorAlarms_FireAlarms_FireAlarmId",
                table: "SmokeDetectorAlarms",
                column: "FireAlarmId",
                principalTable: "FireAlarms",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_HttpNotification_AutomationSettings_AutomationSettingId",
                table: "HttpNotification");

            migrationBuilder.DropForeignKey(
                name: "FK_HttpNotification_NotificationSettings_NotificationSettingId",
                table: "HttpNotification");

            migrationBuilder.DropForeignKey(
                name: "FK_HttpNotification_PreAlarmAutomationSettings_PreAlarmAutomat~",
                table: "HttpNotification");

            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectorAlarms_FireAlarms_FireAlarmId",
                table: "SmokeDetectorAlarms");

            migrationBuilder.DropTable(
                name: "ApiKeys");

            migrationBuilder.DropTable(
                name: "AutomationEmailNotification");

            migrationBuilder.DropTable(
                name: "FireAlarms");

            migrationBuilder.DropTable(
                name: "MqttConnectionData");

            migrationBuilder.DropTable(
                name: "PhoneCallNotification");

            migrationBuilder.DropTable(
                name: "SmsNotification");

            migrationBuilder.DropTable(
                name: "UserEmailNotification");

            migrationBuilder.DropTable(
                name: "PreAlarmAutomationSettings");

            migrationBuilder.DropIndex(
                name: "IX_SmokeDetectorAlarms_FireAlarmId",
                table: "SmokeDetectorAlarms");

            migrationBuilder.DropIndex(
                name: "IX_HttpNotification_AutomationSettingId",
                table: "HttpNotification");

            migrationBuilder.DropIndex(
                name: "IX_HttpNotification_PreAlarmAutomationSettingId",
                table: "HttpNotification");

            migrationBuilder.DropIndex(
                name: "IX_AutomationSettings_BuildingUnitId",
                table: "AutomationSettings");

            migrationBuilder.DropColumn(
                name: "SupportsBatteryAlarm",
                table: "SmokeDetectorModels");

            migrationBuilder.DropColumn(
                name: "SupportsRemoteAlarm",
                table: "SmokeDetectorModels");

            migrationBuilder.DropColumn(
                name: "Signature",
                table: "SmokeDetectorMaintenances");

            migrationBuilder.DropColumn(
                name: "FireAlarmId",
                table: "SmokeDetectorAlarms");

            migrationBuilder.DropColumn(
                name: "AutomationSettingId",
                table: "HttpNotification");

            migrationBuilder.DropColumn(
                name: "PreAlarmAutomationSettingId",
                table: "HttpNotification");

            migrationBuilder.DropColumn(
                name: "MqttText",
                table: "BuildingUnits");

            migrationBuilder.DropColumn(
                name: "SendMqttInfo",
                table: "BuildingUnits");

            migrationBuilder.DropColumn(
                name: "SendPreAlarm",
                table: "BuildingUnits");

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Tenants",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectors",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectorModels",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectorMaintenances",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "SmokeDetectorAlarms",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "EndTime",
                table: "SmokeDetectorAlarms",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Rooms",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "PushNotificationToken",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "NotificationSettings",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "NotificationSettings",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PhoneNumber",
                table: "NotificationSettings",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "SMSNumber",
                table: "NotificationSettings",
                type: "text",
                nullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "NotificationSettingId",
                table: "HttpNotification",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "HttpNotification",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Header",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Gateways",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "BuildingUnits",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Buildings",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "AutomationSettings",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Name",
                table: "Addresses",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_AutomationSettings_BuildingUnitId",
                table: "AutomationSettings",
                column: "BuildingUnitId");

            migrationBuilder.AddForeignKey(
                name: "FK_HttpNotification_NotificationSettings_NotificationSettingId",
                table: "HttpNotification",
                column: "NotificationSettingId",
                principalTable: "NotificationSettings",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
