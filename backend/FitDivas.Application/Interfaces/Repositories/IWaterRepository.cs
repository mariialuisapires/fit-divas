using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Repositories;

public interface IWaterRepository
{
    Task<WaterHistory> AddAsync(WaterHistory entry);
    Task<List<WaterHistory>> GetByDateAsync(Guid userId, DateTime date);
    Task<List<WaterHistory>> GetByMonthAsync(Guid userId, int year, int month);
    Task DeleteAsync(WaterHistory entry);
}
