using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Repositories;

public interface IWeightGoalRepository
{
    Task<WeightGoal?> GetActiveByUserAsync(Guid userId);
    Task<List<WeightGoal>> GetFinishedByUserAsync(Guid userId);
    Task AddAsync(WeightGoal goal);
    Task UpdateAsync(WeightGoal goal);
}
