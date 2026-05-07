using FitDivas.Application.DTOs.Auth;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;
using FitDivas.Domain.Entities;

namespace FitDivas.Application.Services;

public class AuthService(IUserRepository userRepository, IJwtTokenService jwtTokenService) : IAuthService
{
    public async Task<AuthResponseDto> RegisterAsync(RegisterDto dto)
    {
        if (await userRepository.EmailExistsAsync(dto.Email))
            throw new InvalidOperationException("Email já cadastrado.");

        var user = new User
        {
            Id = Guid.NewGuid(),
            Nome = dto.Nome,
            Email = dto.Email.ToLowerInvariant(),
            SenhaHash = BCrypt.Net.BCrypt.HashPassword(dto.Senha),
            Altura = dto.Altura
        };

        await userRepository.CreateAsync(user);

        return new AuthResponseDto
        {
            Token = jwtTokenService.GenerateToken(user),
            UserId = user.Id,
            Nome = user.Nome,
            Email = user.Email
        };
    }

    public async Task<AuthResponseDto> LoginAsync(LoginDto dto)
    {
        var user = await userRepository.GetByEmailAsync(dto.Email.ToLowerInvariant())
            ?? throw new UnauthorizedAccessException("Email ou senha inválidos.");

        if (!BCrypt.Net.BCrypt.Verify(dto.Senha, user.SenhaHash))
            throw new UnauthorizedAccessException("Email ou senha inválidos.");

        return new AuthResponseDto
        {
            Token = jwtTokenService.GenerateToken(user),
            UserId = user.Id,
            Nome = user.Nome,
            Email = user.Email
        };
    }

    public async Task<UserProfileDto> GetProfileAsync(Guid userId)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");
        return MapToProfileDto(user);
    }

    public async Task<UserProfileDto> UpdateProfileAsync(Guid userId, UpdateProfileDto dto)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");

        if (dto.Nome is not null) user.Nome = dto.Nome;
        if (dto.PesoAtual.HasValue) user.PesoAtual = dto.PesoAtual;
        if (dto.PesoMeta.HasValue) user.PesoMeta = dto.PesoMeta;
        if (dto.Altura.HasValue) user.Altura = dto.Altura;
        if (dto.FcmToken is not null) user.FcmToken = dto.FcmToken;
        if (dto.MetaAguaMl.HasValue) user.MetaAguaMl = dto.MetaAguaMl.Value;

        await userRepository.UpdateAsync(user);
        return MapToProfileDto(user);
    }

    private static UserProfileDto MapToProfileDto(User user) => new()
    {
        Id = user.Id,
        Nome = user.Nome,
        Email = user.Email,
        PesoAtual = user.PesoAtual,
        PesoMeta = user.PesoMeta,
        Altura = user.Altura,
        MetaAguaMl = user.MetaAguaMl
    };
}
