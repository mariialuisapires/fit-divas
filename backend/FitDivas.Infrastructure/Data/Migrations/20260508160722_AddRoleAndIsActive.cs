using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitDivas.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddRoleAndIsActive : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "is_active",
                table: "users",
                type: "boolean",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<string>(
                name: "role",
                table: "users",
                type: "character varying(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "user");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "is_active",
                table: "users");

            migrationBuilder.DropColumn(
                name: "role",
                table: "users");
        }
    }
}
