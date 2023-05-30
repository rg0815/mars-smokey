using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class RemoveFloorFromRoom : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Floor",
                table: "Rooms");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Floor",
                table: "Rooms",
                type: "text",
                nullable: false,
                defaultValue: "");
        }
    }
}
