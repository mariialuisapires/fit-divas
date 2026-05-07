using FitDivas.Application.DTOs.Water;

namespace FitDivas.Application.Interfaces.Services;

public interface IWaterService
{
    Task<WaterSummaryDto> GetTodaySummaryAsync(Guid userId);
    Task<WaterSummaryDto> AddWaterAsync(Guid userId, AddWaterDto dto);
    Task<List<WaterMonthlyDto>> GetMonthlyHistoryAsync(Guid userId, int year, int month);
    Task SetGoalAsync(Guid userId, SetWaterGoalDto dto);
    Task RemoveEntryAsync(Guid entryId, Guid userId);
}
