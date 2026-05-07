using FitDivas.Application.DTOs.Weight;

namespace FitDivas.Application.Interfaces.Services;

public interface IWeightService
{
    Task<WeightGoalResponseDto> CreateGoalAsync(Guid userId, CreateWeightGoalDto dto);
    Task<WeightGoalResponseDto?> GetActiveGoalAsync(Guid userId);
    Task<List<WeightGoalHistoryItemDto>> GetGoalHistoryAsync(Guid userId);
    Task<WeightProgressDto> AddWeightAsync(Guid userId, AddWeightDto dto);
}
