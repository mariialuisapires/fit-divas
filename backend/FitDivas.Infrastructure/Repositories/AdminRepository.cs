using FitDivas.Application.DTOs.Admin;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using static FitDivas.Domain.Entities.ChallengeStatus;

namespace FitDivas.Infrastructure.Repositories;

public class AdminRepository(FitDivasDbContext context) : IAdminRepository
{
    public async Task<List<User>> GetAllUsersAsync() =>
        await context.Users
            .Where(u => u.Role != "admin")
            .OrderByDescending(u => u.CriadoEm)
            .ToListAsync();

    public async Task<DashboardStatsDto> GetDashboardStatsAsync()
    {
        var totalUsuarios = await context.Users.CountAsync(u => u.Role != "admin");
        var usuariosAtivos = await context.Users.CountAsync(u => u.Role != "admin" && u.IsActive);
        var desafiosAtivos = await context.Challenges.CountAsync(c => c.Status == Ativo);
        var treinosConcluidos = await context.WorkoutHistories.CountAsync();
        var metasAtivas = await context.WeightGoals.CountAsync(g => g.Status == "ativo");

        return new DashboardStatsDto
        {
            TotalUsuarios = totalUsuarios,
            UsuariosAtivos = usuariosAtivos,
            UsuariosBloqueados = totalUsuarios - usuariosAtivos,
            DesafiosAtivos = desafiosAtivos,
            TreinosConcluidos = treinosConcluidos,
            MetasAtivas = metasAtivas,
        };
    }
}
