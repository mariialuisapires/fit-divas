using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitDivas.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddWeightGoal : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "weight_goals",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    peso_inicial = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    peso_meta = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    tipo = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    data_inicio = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    data_fim = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "ativo")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_weight_goals", x => x.id);
                    table.ForeignKey(
                        name: "FK_weight_goals_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_weight_goals_user_id_status",
                table: "weight_goals",
                columns: new[] { "user_id", "status" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "weight_goals");
        }
    }
}
