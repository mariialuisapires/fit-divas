using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FitDivas.Infrastructure.Repositories;

public class WeightGoalRepository(FitDivasDbContext context) : IWeightGoalRepository
{
    public async Task<WeightGoal?> GetActiveByUserAsync(Guid userId) =>
        await context.WeightGoals.FirstOrDefaultAsync(g => g.UserId == userId && g.Status == "ativo");

    public async Task<List<WeightGoal>> GetFinishedByUserAsync(Guid userId) =>
        await context.WeightGoals
            .Where(g => g.UserId == userId && g.Status == "finalizado")
            .OrderByDescending(g => g.DataInicio)
            .ToListAsync();

    public async Task AddAsync(WeightGoal goal)
    {
        context.WeightGoals.Add(goal);
        await context.SaveChangesAsync();
    }

    public async Task UpdateAsync(WeightGoal goal)
    {
        context.WeightGoals.Update(goal);
        await context.SaveChangesAsync();
    }
}
