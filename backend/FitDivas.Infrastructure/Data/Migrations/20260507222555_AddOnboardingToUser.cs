using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitDivas.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddOnboardingToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Genero",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Idade",
                table: "users",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Objetivo",
                table: "users",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Genero",
                table: "users");

            migrationBuilder.DropColumn(
                name: "Idade",
                table: "users");

            migrationBuilder.DropColumn(
                name: "Objetivo",
                table: "users");
        }
    }
}
