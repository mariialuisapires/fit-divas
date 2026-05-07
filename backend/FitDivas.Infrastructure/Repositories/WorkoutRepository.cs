using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FitDivas.Infrastructure.Repositories;

public class WorkoutRepository(FitDivasDbContext context) : IWorkoutRepository
{
    public async Task<Workout?> GetByIdAsync(Guid id, Guid userId) =>
        await context.Workouts
            .Include(w => w.Exercicios)
            .FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);

    public async Task<List<Workout>> GetAllByUserAsync(Guid userId) =>
        await context.Workouts
            .Include(w => w.Exercicios)
            .Where(w => w.UserId == userId)
            .OrderBy(w => w.Nome)
            .ToListAsync();

    public async Task<Workout> CreateAsync(Workout workout)
    {
        context.Workouts.Add(workout);
        await context.SaveChangesAsync();
        return workout;
    }

    public async Task<Workout> UpdateAsync(Workout workout)
    {
        var existing = await context.Workouts
            .Include(w => w.Exercicios)
            .FirstAsync(w => w.Id == workout.Id);

        context.Exercises.RemoveRange(existing.Exercicios);
        existing.Nome = workout.Nome;
        existing.Observacoes = workout.Observacoes;
        existing.Exercicios = workout.Exercicios;

        await context.SaveChangesAsync();
        return existing;
    }

    public async Task DeleteAsync(Workout workout)
    {
        context.Workouts.Remove(workout);
        await context.SaveChangesAsync();
    }

    public async Task<WorkoutHistory> AddHistoryAsync(WorkoutHistory history)
    {
        context.WorkoutHistories.Add(history);
        await context.SaveChangesAsync();
        return history;
    }

    public async Task<List<WorkoutHistory>> GetHistoryByMonthAsync(Guid userId, int year, int month)
    {
        var start = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
        var end = start.AddMonths(1);

        return await context.WorkoutHistories
            .Include(h => h.Workout)
            .Where(h => h.UserId == userId && h.DataConclusao >= start && h.DataConclusao < end)
            .OrderBy(h => h.DataConclusao)
            .ToListAsync();
    }

    public async Task<List<WorkoutHistory>> GetHistoryByDateRangeAsync(Guid userId, DateTime start, DateTime end) =>
        await context.WorkoutHistories
            .Where(h => h.UserId == userId && h.DataConclusao >= start && h.DataConclusao <= end)
            .OrderBy(h => h.DataConclusao)
            .ToListAsync();
}
