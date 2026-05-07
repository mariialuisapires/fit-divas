using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitDivas.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddDiaSemanaToWorkout : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "dia_semana",
                table: "workouts",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "dia_semana",
                table: "workouts");
        }
    }
}
