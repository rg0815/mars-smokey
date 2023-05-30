using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class RWMMQTT : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsViaMqtt",
                table: "SmokeDetectors",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "MqttMessage",
                table: "SmokeDetectors",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MqttTopic",
                table: "SmokeDetectors",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ClientId",
                table: "MqttConnectionData",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsViaMqtt",
                table: "SmokeDetectors");

            migrationBuilder.DropColumn(
                name: "MqttMessage",
                table: "SmokeDetectors");

            migrationBuilder.DropColumn(
                name: "MqttTopic",
                table: "SmokeDetectors");

            migrationBuilder.DropColumn(
                name: "ClientId",
                table: "MqttConnectionData");
        }
    }
}
