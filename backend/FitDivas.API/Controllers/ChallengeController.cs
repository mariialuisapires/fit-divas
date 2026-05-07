using System.Security.Claims;
using FitDivas.Application.DTOs.Challenge;
using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/challenges")]
[Authorize]
public class ChallengeController(IChallengeService challengeService) : ControllerBase
{
    [HttpGet("active")]
    public async Task<IActionResult> GetActive()
    {
        var result = await challengeService.GetActiveAsync(GetUserId());
        return result is null ? NotFound() : Ok(result);
    }

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await challengeService.GetAllAsync(GetUserId()));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateChallengeDto dto)
    {
        var result = await challengeService.CreateAsync(GetUserId(), dto);
        return CreatedAtAction(nameof(GetActive), result);
    }

    [HttpPost("{id:guid}/finish")]
    public async Task<IActionResult> Finish(Guid id) =>
        Ok(await challengeService.FinishAsync(id, GetUserId()));

    [HttpPost("{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id) =>
        Ok(await challengeService.CancelAsync(id, GetUserId()));

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
