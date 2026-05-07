using System.Security.Cryptography;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FitDivas.Infrastructure.Repositories;

public class RefreshTokenRepository(FitDivasDbContext context) : IRefreshTokenRepository
{
    public async Task<RefreshToken> CreateAsync(Guid userId)
    {
        var token = new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
            ExpiresAt = DateTime.UtcNow.AddDays(30),
            CreatedAt = DateTime.UtcNow,
            IsRevoked = false
        };
        context.RefreshTokens.Add(token);
        await context.SaveChangesAsync();
        return token;
    }

    public async Task<RefreshToken?> GetByTokenAsync(string token) =>
        await context.RefreshTokens
            .FirstOrDefaultAsync(t => t.Token == token);

    public async Task RevokeAsync(RefreshToken refreshToken)
    {
        refreshToken.IsRevoked = true;
        await context.SaveChangesAsync();
    }
}
