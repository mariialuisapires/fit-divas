using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FitDivas.Infrastructure.Repositories;

public class WaterRepository(FitDivasDbContext context) : IWaterRepository
{
    public async Task<WaterHistory> AddAsync(WaterHistory entry)
    {
        context.WaterHistories.Add(entry);
        await context.SaveChangesAsync();
        return entry;
    }

    public async Task<List<WaterHistory>> GetByDateAsync(Guid userId, DateTime date)
    {
        var start = date.Date.ToUniversalTime();
        var end = start.AddDays(1);
        return await context.WaterHistories
            .Where(h => h.UserId == userId && h.DataRegistro >= start && h.DataRegistro < end)
            .OrderBy(h => h.DataRegistro)
            .ToListAsync();
    }

    public async Task<List<WaterHistory>> GetByMonthAsync(Guid userId, int year, int month)
    {
        var start = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
        var end = start.AddMonths(1);
        return await context.WaterHistories
            .Where(h => h.UserId == userId && h.DataRegistro >= start && h.DataRegistro < end)
            .OrderBy(h => h.DataRegistro)
            .ToListAsync();
    }

    public async Task DeleteAsync(WaterHistory entry)
    {
        context.WaterHistories.Remove(entry);
        await context.SaveChangesAsync();
    }
}
