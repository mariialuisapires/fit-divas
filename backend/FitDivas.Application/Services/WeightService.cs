using FitDivas.Application.DTOs.Weight;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;
using FitDivas.Domain.Entities;

namespace FitDivas.Application.Services;

public class WeightService(IWeightRepository weightRepository, IUserRepository userRepository) : IWeightService
{
    public async Task<WeightSummaryDto> GetSummaryAsync(Guid userId)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");

        var now = DateTime.UtcNow;
        var history = await weightRepository.GetByMonthAsync(userId, now.Year, now.Month);
        var latest = await weightRepository.GetLatestAsync(userId);

        var pesoInicial = history.OrderBy(h => h.DataRegistro).FirstOrDefault()?.Peso ?? user.PesoAtual;

        return new WeightSummaryDto
        {
            PesoInicial = pesoInicial,
            PesoAtual = latest?.Peso ?? user.PesoAtual,
            PesoMeta = user.PesoMeta,
            Diferenca = latest is not null && pesoInicial.HasValue
                ? latest.Peso - pesoInicial.Value
                : null,
            Historico = history.Select(h => new WeightProgressDto
            {
                Id = h.Id,
                Peso = h.Peso,
                DataRegistro = h.DataRegistro
            }).ToList()
        };
    }

    public async Task<WeightProgressDto> AddWeightAsync(Guid userId, AddWeightDto dto)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");

        var entry = new WeightProgress
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Peso = dto.Peso,
            DataRegistro = dto.DataRegistro?.ToUniversalTime() ?? DateTime.UtcNow
        };

        user.PesoAtual = dto.Peso;
        await userRepository.UpdateAsync(user);
        await weightRepository.AddAsync(entry);

        return new WeightProgressDto
        {
            Id = entry.Id,
            Peso = entry.Peso,
            DataRegistro = entry.DataRegistro
        };
    }

    public async Task<List<WeightProgressDto>> GetMonthlyHistoryAsync(Guid userId, int year, int month)
    {
        var history = await weightRepository.GetByMonthAsync(userId, year, month);
        return history.Select(h => new WeightProgressDto
        {
            Id = h.Id,
            Peso = h.Peso,
            DataRegistro = h.DataRegistro
        }).ToList();
    }
}
