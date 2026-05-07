using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FitDivas.Infrastructure.Repositories;

public class ChallengeRepository(FitDivasDbContext context) : IChallengeRepository
{
    public async Task<Challenge?> GetActiveByUserAsync(Guid userId) =>
        await context.Challenges
            .FirstOrDefaultAsync(c => c.UserId == userId && c.Status == ChallengeStatus.Ativo);

    public async Task<Challenge?> GetByIdAsync(Guid id, Guid userId) =>
        await context.Challenges.FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId);

    public async Task<List<Challenge>> GetAllByUserAsync(Guid userId) =>
        await context.Challenges
            .Where(c => c.UserId == userId)
            .OrderByDescending(c => c.DataInicio)
            .ToListAsync();

    public async Task<Challenge> CreateAsync(Challenge challenge)
    {
        context.Challenges.Add(challenge);
        await context.SaveChangesAsync();
        return challenge;
    }

    public async Task<Challenge> UpdateAsync(Challenge challenge)
    {
        context.Challenges.Update(challenge);
        await context.SaveChangesAsync();
        return challenge;
    }
}
