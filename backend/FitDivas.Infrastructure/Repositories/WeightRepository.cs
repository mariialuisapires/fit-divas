using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FitDivas.Infrastructure.Repositories;

public class WeightRepository(FitDivasDbContext context) : IWeightRepository
{
    public async Task<WeightProgress> AddAsync(WeightProgress entry)
    {
        context.WeightProgresses.Add(entry);
        await context.SaveChangesAsync();
        return entry;
    }

    public async Task<List<WeightProgress>> GetByMonthAsync(Guid userId, int year, int month)
    {
        var start = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
        var end = start.AddMonths(1);
        return await context.WeightProgresses
            .Where(w => w.UserId == userId && w.DataRegistro >= start && w.DataRegistro < end)
            .OrderBy(w => w.DataRegistro)
            .ToListAsync();
    }

    public async Task<List<WeightProgress>> GetByDateRangeAsync(Guid userId, DateTime from, DateTime to) =>
        await context.WeightProgresses
            .Where(w => w.UserId == userId && w.DataRegistro >= from && w.DataRegistro <= to)
            .OrderBy(w => w.DataRegistro)
            .ToListAsync();

    public async Task<WeightProgress?> GetLatestAsync(Guid userId) =>
        await context.WeightProgresses
            .Where(w => w.UserId == userId)
            .OrderByDescending(w => w.DataRegistro)
            .FirstOrDefaultAsync();
}
