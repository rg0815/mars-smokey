using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backenduserservice.Migrations
{
    /// <inheritdoc />
    public partial class UserInvitationTenantAdmin : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsTenantAdmin",
                table: "UserInvitations",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsTenantAdmin",
                table: "UserInvitations");
        }
    }
}
