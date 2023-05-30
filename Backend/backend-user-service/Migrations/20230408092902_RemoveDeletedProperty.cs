using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backenduserservice.Migrations
{
    /// <inheritdoc />
    public partial class RemoveDeletedProperty : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "AspNetUsers");

            migrationBuilder.RenameColumn(
                name: "isDeleted",
                table: "UserInvitations",
                newName: "IsDeleted");

            migrationBuilder.RenameColumn(
                name: "isAccepted",
                table: "UserInvitations",
                newName: "IsAccepted");

            migrationBuilder.RenameColumn(
                name: "Role",
                table: "UserInvitations",
                newName: "WriteAccess");

            migrationBuilder.AddColumn<List<string>>(
                name: "ReadAccess",
                table: "UserInvitations",
                type: "text[]",
                nullable: false);

            migrationBuilder.AddColumn<Guid>(
                name: "TenantId",
                table: "UserInvitations",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ReadAccess",
                table: "UserInvitations");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "UserInvitations");

            migrationBuilder.RenameColumn(
                name: "IsDeleted",
                table: "UserInvitations",
                newName: "isDeleted");

            migrationBuilder.RenameColumn(
                name: "IsAccepted",
                table: "UserInvitations",
                newName: "isAccepted");

            migrationBuilder.RenameColumn(
                name: "WriteAccess",
                table: "UserInvitations",
                newName: "Role");

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "AspNetUsers",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }
    }
}
