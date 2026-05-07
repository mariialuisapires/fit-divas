using FitDivas.Application.DTOs.Challenge;

namespace FitDivas.Application.Interfaces.Services;

public interface IChallengeService
{
    Task<ChallengeResponseDto?> GetActiveAsync(Guid userId);
    Task<List<ChallengeResponseDto>> GetAllAsync(Guid userId);
    Task<ChallengeResponseDto> CreateAsync(Guid userId, CreateChallengeDto dto);
    Task<ChallengeResponseDto> FinishAsync(Guid id, Guid userId);
    Task<ChallengeResponseDto> CancelAsync(Guid id, Guid userId);
}
