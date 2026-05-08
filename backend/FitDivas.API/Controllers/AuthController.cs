using System.Security.Claims;
using FitDivas.Application.DTOs.Auth;
using FitDivas.Application.DTOs.Weight;
using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService authService, IWeightService weightService) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        var result = await authService.RegisterAsync(dto);
        return CreatedAtAction(nameof(GetProfile), result);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var result = await authService.LoginAsync(dto);
        return Ok(result);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequestDto dto)
    {
        var result = await authService.RefreshAsync(dto.RefreshToken);
        return Ok(result);
    }

    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
    {
        var userId = GetUserId();
        var result = await authService.GetProfileAsync(userId);
        return Ok(result);
    }

    [HttpPut("profile")]
    [Authorize]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
    {
        var userId = GetUserId();
        var result = await authService.UpdateProfileAsync(userId, dto);
        return Ok(result);
    }

    [HttpDelete("account")]
    [Authorize]
    public async Task<IActionResult> DeleteAccount([FromBody] DeleteAccountDto dto)
    {
        await authService.DeleteAccountAsync(GetUserId(), dto);
        return NoContent();
    }

    [HttpPost("onboarding")]
    [Authorize]
    public async Task<IActionResult> CompleteOnboarding([FromBody] CompleteOnboardingDto dto)
    {
        var userId = GetUserId();

        var user = await authService.UpdateProfileAsync(userId, new UpdateProfileDto
        {
            Genero = dto.Genero,
            Objetivo = dto.Objetivo,
            Idade = dto.Idade,
            Altura = dto.Altura,
            PesoAtual = dto.PesoAtual,
        });

        var goal = await weightService.CreateGoalAsync(userId, new CreateWeightGoalDto
        {
            PesoAtual = dto.PesoAtual,
            PesoMeta = dto.PesoMeta,
        });

        return Ok(new { user, goal });
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
