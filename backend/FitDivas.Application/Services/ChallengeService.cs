using FitDivas.Application.DTOs.Challenge;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;
using FitDivas.Domain.Entities;

namespace FitDivas.Application.Services;

public class ChallengeService(
    IChallengeRepository challengeRepository,
    IWorkoutRepository workoutRepository,
    IWeightRepository weightRepository) : IChallengeService
{
    public async Task<ChallengeResponseDto?> GetActiveAsync(Guid userId)
    {
        var challenge = await challengeRepository.GetActiveByUserAsync(userId);
        if (challenge is null) return null;
        return await MapToDtoAsync(challenge, userId);
    }

    public async Task<List<ChallengeResponseDto>> GetAllAsync(Guid userId)
    {
        var challenges = await challengeRepository.GetAllByUserAsync(userId);
        var result = new List<ChallengeResponseDto>();
        foreach (var c in challenges)
            result.Add(await MapToDtoAsync(c, userId));
        return result;
    }

    public async Task<ChallengeResponseDto> CreateAsync(Guid userId, CreateChallengeDto dto)
    {
        var active = await challengeRepository.GetActiveByUserAsync(userId);
        if (active is not null)
            throw new InvalidOperationException("Já existe um desafio ativo. Finalize-o antes de criar outro.");

        if ((dto.DataFim - dto.DataInicio).TotalDays > 31)
            throw new InvalidOperationException("O desafio não pode ter duração maior que 31 dias.");

        var challenge = new Challenge
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Nome = dto.Nome,
            PesoInicial = dto.PesoInicial,
            PesoMeta = dto.PesoMeta,
            MetaDiasTreinados = dto.MetaDiasTreinados,
            DataInicio = dto.DataInicio.ToUniversalTime(),
            DataFim = dto.DataFim.ToUniversalTime(),
            Status = ChallengeStatus.Ativo
        };

        await challengeRepository.CreateAsync(challenge);
        return await MapToDtoAsync(challenge, userId);
    }

    public async Task<ChallengeResponseDto> FinishAsync(Guid id, Guid userId)
    {
        var challenge = await challengeRepository.GetByIdAsync(id, userId)
            ?? throw new KeyNotFoundException("Desafio não encontrado.");

        challenge.Status = ChallengeStatus.Concluido;
        await challengeRepository.UpdateAsync(challenge);
        return await MapToDtoAsync(challenge, userId);
    }

    public async Task<ChallengeResponseDto> CancelAsync(Guid id, Guid userId)
    {
        var challenge = await challengeRepository.GetByIdAsync(id, userId)
            ?? throw new KeyNotFoundException("Desafio não encontrado.");

        challenge.Status = ChallengeStatus.Cancelado;
        await challengeRepository.UpdateAsync(challenge);
        return await MapToDtoAsync(challenge, userId);
    }

    private async Task<ChallengeResponseDto> MapToDtoAsync(Challenge challenge, Guid userId)
    {
        var history = await workoutRepository.GetHistoryByDateRangeAsync(userId, challenge.DataInicio, challenge.DataFim);
        var diasTreinados = history.Select(h => h.DataConclusao.Date).Distinct().Count();
        var diasTotais = (int)(challenge.DataFim - challenge.DataInicio).TotalDays + 1;

        var latestWeight = await weightRepository.GetLatestAsync(userId);

        return new ChallengeResponseDto
        {
            Id = challenge.Id,
            Nome = challenge.Nome,
            PesoInicial = challenge.PesoInicial,
            PesoMeta = challenge.PesoMeta,
            MetaDiasTreinados = challenge.MetaDiasTreinados,
            DataInicio = challenge.DataInicio,
            DataFim = challenge.DataFim,
            Status = challenge.Status,
            DiasTreinados = diasTreinados,
            DiasTotais = diasTotais,
            ProgressoPercentual = challenge.MetaDiasTreinados > 0
                ? Math.Min(100.0, (double)diasTreinados / challenge.MetaDiasTreinados * 100)
                : 0,
            PesoAtual = latestWeight?.Peso
        };
    }
}
