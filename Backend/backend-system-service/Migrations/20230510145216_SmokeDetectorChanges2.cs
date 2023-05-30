using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class SmokeDetectorChanges2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectors_Rooms_RoomId",
                table: "SmokeDetectors");

            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModel_SmokeDetectorModelId",
                table: "SmokeDetectors");

            migrationBuilder.DropPrimaryKey(
                name: "PK_SmokeDetectorModel",
                table: "SmokeDetectorModel");

            migrationBuilder.RenameTable(
                name: "SmokeDetectorModel",
                newName: "SmokeDetectorModels");

            migrationBuilder.AlterColumn<Guid>(
                name: "SmokeDetectorModelId",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<Guid>(
                name: "RoomId",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<string>(
                name: "RawTransmissionData",
                table: "SmokeDetectors",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddPrimaryKey(
                name: "PK_SmokeDetectorModels",
                table: "SmokeDetectorModels",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectors_Rooms_RoomId",
                table: "SmokeDetectors",
                column: "RoomId",
                principalTable: "Rooms",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModels_SmokeDetectorModelId",
                table: "SmokeDetectors",
                column: "SmokeDetectorModelId",
                principalTable: "SmokeDetectorModels",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectors_Rooms_RoomId",
                table: "SmokeDetectors");

            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModels_SmokeDetectorModelId",
                table: "SmokeDetectors");

            migrationBuilder.DropPrimaryKey(
                name: "PK_SmokeDetectorModels",
                table: "SmokeDetectorModels");

            migrationBuilder.RenameTable(
                name: "SmokeDetectorModels",
                newName: "SmokeDetectorModel");

            migrationBuilder.AlterColumn<Guid>(
                name: "SmokeDetectorModelId",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "RoomId",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "RawTransmissionData",
                table: "SmokeDetectors",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_SmokeDetectorModel",
                table: "SmokeDetectorModel",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectors_Rooms_RoomId",
                table: "SmokeDetectors",
                column: "RoomId",
                principalTable: "Rooms",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModel_SmokeDetectorModelId",
                table: "SmokeDetectors",
                column: "SmokeDetectorModelId",
                principalTable: "SmokeDetectorModel",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
