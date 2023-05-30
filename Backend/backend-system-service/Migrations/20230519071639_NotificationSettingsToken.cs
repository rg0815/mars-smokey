using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class NotificationSettingsToken : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PushNotificationTokens",
                table: "NotificationSettings");

            migrationBuilder.CreateTable(
                name: "PushNotificationToken",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    NotificationSettingId = table.Column<Guid>(type: "uuid", nullable: false),
                    Token = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PushNotificationToken", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PushNotificationToken_NotificationSettings_NotificationSett~",
                        column: x => x.NotificationSettingId,
                        principalTable: "NotificationSettings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PushNotificationToken_NotificationSettingId",
                table: "PushNotificationToken",
                column: "NotificationSettingId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PushNotificationToken");

            migrationBuilder.AddColumn<List<string>>(
                name: "PushNotificationTokens",
                table: "NotificationSettings",
                type: "text[]",
                nullable: false);
        }
    }
}
