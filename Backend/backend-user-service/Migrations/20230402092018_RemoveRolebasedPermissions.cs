using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backenduserservice.Migrations
{
    /// <inheritdoc />
    public partial class RemoveRolebasedPermissions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<List<string>>(
                name: "ReadAccess",
                table: "AspNetUsers",
                type: "text[]",
                nullable: false);

            migrationBuilder.AddColumn<List<string>>(
                name: "WriteAccess",
                table: "AspNetUsers",
                type: "text[]",
                nullable: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ReadAccess",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "WriteAccess",
                table: "AspNetUsers");
        }
    }
}
