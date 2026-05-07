using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Repositories;

public interface IWorkoutRepository
{
    Task<Workout?> GetByIdAsync(Guid id, Guid userId);
    Task<List<Workout>> GetAllByUserAsync(Guid userId);
    Task<Workout> CreateAsync(Workout workout);
    Task<Workout> UpdateAsync(Workout workout);
    Task DeleteAsync(Workout workout);
    Task<WorkoutHistory> AddHistoryAsync(WorkoutHistory history);
    Task<List<WorkoutHistory>> GetHistoryByMonthAsync(Guid userId, int year, int month);
    Task<List<WorkoutHistory>> GetHistoryByDateRangeAsync(Guid userId, DateTime start, DateTime end);
}
