using FitDivas.Application.DTOs.Weight;

namespace FitDivas.Application.Interfaces.Services;

public interface IWeightService
{
    Task<WeightSummaryDto> GetSummaryAsync(Guid userId);
    Task<WeightProgressDto> AddWeightAsync(Guid userId, AddWeightDto dto);
    Task<List<WeightProgressDto>> GetMonthlyHistoryAsync(Guid userId, int year, int month);
}
