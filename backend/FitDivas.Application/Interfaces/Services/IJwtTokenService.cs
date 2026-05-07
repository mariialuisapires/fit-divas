using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Services;

public interface IJwtTokenService
{
    string GenerateToken(User user);
}
