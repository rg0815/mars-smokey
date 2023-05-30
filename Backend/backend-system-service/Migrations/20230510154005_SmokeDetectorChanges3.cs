using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend_system_service.Migrations
{
    /// <inheritdoc />
    public partial class SmokeDetectorChanges3 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModels_SmokeDetectorModelId",
                table: "SmokeDetectors");

            migrationBuilder.AlterColumn<Guid>(
                name: "SmokeDetectorModelId",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModels_SmokeDetectorModelId",
                table: "SmokeDetectors",
                column: "SmokeDetectorModelId",
                principalTable: "SmokeDetectorModels",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModels_SmokeDetectorModelId",
                table: "SmokeDetectors");

            migrationBuilder.AlterColumn<Guid>(
                name: "SmokeDetectorModelId",
                table: "SmokeDetectors",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddForeignKey(
                name: "FK_SmokeDetectors_SmokeDetectorModels_SmokeDetectorModelId",
                table: "SmokeDetectors",
                column: "SmokeDetectorModelId",
                principalTable: "SmokeDetectorModels",
                principalColumn: "Id");
        }
    }
}
