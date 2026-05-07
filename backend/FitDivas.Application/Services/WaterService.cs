using FitDivas.Application.DTOs.Water;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;
using FitDivas.Domain.Entities;

namespace FitDivas.Application.Services;

public class WaterService(IWaterRepository waterRepository, IUserRepository userRepository) : IWaterService
{
    private const int DefaultGoalMl = 2000;

    public async Task<WaterSummaryDto> GetTodaySummaryAsync(Guid userId)
    {
        var today = DateTime.UtcNow.Date;
        var (entries, goal) = await GetEntriesAndGoalAsync(userId, today);
        return BuildSummary(entries, goal);
    }

    public async Task<WaterSummaryDto> AddWaterAsync(Guid userId, AddWaterDto dto)
    {
        var entry = new WaterHistory
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            QuantidadeMl = dto.QuantidadeMl,
            DataRegistro = DateTime.UtcNow
        };

        await waterRepository.AddAsync(entry);

        var today = DateTime.UtcNow.Date;
        var (entries, goal) = await GetEntriesAndGoalAsync(userId, today);
        return BuildSummary(entries, goal);
    }

    public async Task<List<WaterMonthlyDto>> GetMonthlyHistoryAsync(Guid userId, int year, int month)
    {
        var user = await userRepository.GetByIdAsync(userId);
        var goal = user?.MetaAguaMl ?? DefaultGoalMl;
        var entries = await waterRepository.GetByMonthAsync(userId, year, month);

        return entries
            .GroupBy(e => e.DataRegistro.Date)
            .Select(g => new WaterMonthlyDto
            {
                Data = g.Key,
                TotalMl = g.Sum(e => e.QuantidadeMl),
                MetaMl = goal,
                MetaAtingida = g.Sum(e => e.QuantidadeMl) >= goal
            })
            .OrderBy(d => d.Data)
            .ToList();
    }

    public async Task SetGoalAsync(Guid userId, SetWaterGoalDto dto)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");
        user.MetaAguaMl = dto.MetaDiariaMl;
        await userRepository.UpdateAsync(user);
    }

    public async Task RemoveEntryAsync(Guid entryId, Guid userId)
    {
        var entries = await waterRepository.GetByDateAsync(userId, DateTime.UtcNow.Date);
        var entry = entries.FirstOrDefault(e => e.Id == entryId)
            ?? throw new KeyNotFoundException("Registro de água não encontrado.");
        await waterRepository.DeleteAsync(entry);
    }

    private async Task<(List<WaterHistory> entries, int goal)> GetEntriesAndGoalAsync(Guid userId, DateTime date)
    {
        var user = await userRepository.GetByIdAsync(userId);
        var goal = user?.MetaAguaMl ?? DefaultGoalMl;
        var entries = await waterRepository.GetByDateAsync(userId, date);
        return (entries, goal);
    }

    private static WaterSummaryDto BuildSummary(List<WaterHistory> entries, int goal)
    {
        var total = entries.Sum(e => e.QuantidadeMl);
        return new WaterSummaryDto
        {
            TotalMlHoje = total,
            MetaDiariaMl = goal,
            PercentualAtingido = goal > 0 ? Math.Min(100.0, (double)total / goal * 100) : 0,
            MetaAtingida = total >= goal,
            RegistrosHoje = entries.Select(e => new WaterHistoryItemDto
            {
                Id = e.Id,
                QuantidadeMl = e.QuantidadeMl,
                DataRegistro = e.DataRegistro
            }).ToList()
        };
    }
}
