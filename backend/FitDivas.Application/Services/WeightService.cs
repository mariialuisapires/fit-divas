using FitDivas.Application.DTOs.Weight;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;
using FitDivas.Domain.Entities;

namespace FitDivas.Application.Services;

public class WeightService(IWeightRepository weightRepository, IWeightGoalRepository weightGoalRepository) : IWeightService
{
    public async Task<WeightGoalResponseDto> CreateGoalAsync(Guid userId, CreateWeightGoalDto dto)
    {
        if (dto.PesoAtual == dto.PesoMeta)
            throw new InvalidOperationException("O peso meta não pode ser igual ao peso atual.");

        var existing = await weightGoalRepository.GetActiveByUserAsync(userId);
        if (existing != null)
            throw new InvalidOperationException("Já existe uma meta ativa.");

        var now = DateTime.UtcNow;
        var tipo = dto.PesoMeta < dto.PesoAtual ? "perda" : "ganho";

        var diferenca = Math.Abs(dto.PesoMeta - dto.PesoAtual);
        var taxaSemanal = tipo == "perda" ? 0.5m : 0.25m;
        var semanas = (int)Math.Ceiling(diferenca / taxaSemanal);
        semanas = Math.Max(semanas, 4);
        var dataFim = now.AddDays(semanas * 7);

        var goal = new WeightGoal
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            PesoInicial = dto.PesoAtual,
            PesoMeta = dto.PesoMeta,
            Tipo = tipo,
            DataInicio = now,
            DataFim = dataFim,
            Status = "ativo"
        };

        await weightGoalRepository.AddAsync(goal);

        var initialEntry = new WeightProgress
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Peso = dto.PesoAtual,
            DataRegistro = now
        };
        await weightRepository.AddAsync(initialEntry);

        return MapGoalToDto(goal, [initialEntry]);
    }

    public async Task<WeightGoalResponseDto?> GetActiveGoalAsync(Guid userId)
    {
        var goal = await weightGoalRepository.GetActiveByUserAsync(userId);
        if (goal == null) return null;

        if (DateTime.UtcNow > goal.DataFim)
        {
            goal.Status = "finalizado";
            await weightGoalRepository.UpdateAsync(goal);
        }

        var progressos = await weightRepository.GetByDateRangeAsync(userId, goal.DataInicio, DateTime.UtcNow);
        return MapGoalToDto(goal, progressos);
    }

    public async Task<List<WeightGoalHistoryItemDto>> GetGoalHistoryAsync(Guid userId)
    {
        var goals = await weightGoalRepository.GetFinishedByUserAsync(userId);
        var result = new List<WeightGoalHistoryItemDto>();

        foreach (var g in goals)
        {
            var progressos = await weightRepository.GetByDateRangeAsync(userId, g.DataInicio, g.DataFim);
            var pesoFinal = progressos.OrderByDescending(p => p.DataRegistro).FirstOrDefault()?.Peso;

            var resultado = "nao_atingida";
            if (pesoFinal.HasValue)
            {
                if (g.Tipo == "perda" && pesoFinal <= g.PesoMeta) resultado = "atingida";
                else if (g.Tipo == "ganho" && pesoFinal >= g.PesoMeta) resultado = "atingida";
            }

            result.Add(new WeightGoalHistoryItemDto
            {
                Id = g.Id,
                PesoInicial = g.PesoInicial,
                PesoMeta = g.PesoMeta,
                Tipo = g.Tipo,
                DataInicio = g.DataInicio,
                DataFim = g.DataFim,
                PesoFinal = pesoFinal,
                Resultado = resultado
            });
        }

        return result;
    }

    public async Task<WeightProgressDto> AddWeightAsync(Guid userId, AddWeightDto dto)
    {
        var entry = new WeightProgress
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Peso = dto.Peso,
            DataRegistro = dto.DataRegistro?.ToUniversalTime() ?? DateTime.UtcNow
        };
        await weightRepository.AddAsync(entry);
        return new WeightProgressDto { Id = entry.Id, Peso = entry.Peso, DataRegistro = entry.DataRegistro };
    }

    private static WeightGoalResponseDto MapGoalToDto(WeightGoal goal, IEnumerable<WeightProgress> progressos)
    {
        var ordered = progressos.OrderBy(p => p.DataRegistro).ToList();
        var ultimo = ordered.LastOrDefault();

        return new WeightGoalResponseDto
        {
            Id = goal.Id,
            PesoInicial = goal.PesoInicial,
            PesoMeta = goal.PesoMeta,
            Tipo = goal.Tipo,
            DataInicio = goal.DataInicio,
            DataFim = goal.DataFim,
            Status = goal.Status,
            UltimoPeso = ultimo?.Peso,
            DiferencaAtual = ultimo is not null ? ultimo.Peso - goal.PesoInicial : null,
            Progressos = ordered.Select(p => new WeightProgressDto { Id = p.Id, Peso = p.Peso, DataRegistro = p.DataRegistro }).ToList()
        };
    }
}
