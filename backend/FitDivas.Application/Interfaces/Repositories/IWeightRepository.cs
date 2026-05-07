using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Repositories;

public interface IWeightRepository
{
    Task<WeightProgress> AddAsync(WeightProgress entry);
    Task<List<WeightProgress>> GetByMonthAsync(Guid userId, int year, int month);
    Task<List<WeightProgress>> GetByDateRangeAsync(Guid userId, DateTime from, DateTime to);
    Task<WeightProgress?> GetLatestAsync(Guid userId);
}
