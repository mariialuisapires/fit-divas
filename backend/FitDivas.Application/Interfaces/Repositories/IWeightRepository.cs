using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Repositories;

public interface IWeightRepository
{
    Task<WeightProgress> AddAsync(WeightProgress entry);
    Task<List<WeightProgress>> GetByMonthAsync(Guid userId, int year, int month);
    Task<WeightProgress?> GetLatestAsync(Guid userId);
}
