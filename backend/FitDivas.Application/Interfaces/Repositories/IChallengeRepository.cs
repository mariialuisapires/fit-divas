using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Repositories;

public interface IChallengeRepository
{
    Task<Challenge?> GetActiveByUserAsync(Guid userId);
    Task<Challenge?> GetByIdAsync(Guid id, Guid userId);
    Task<List<Challenge>> GetAllByUserAsync(Guid userId);
    Task<Challenge> CreateAsync(Challenge challenge);
    Task<Challenge> UpdateAsync(Challenge challenge);
}
