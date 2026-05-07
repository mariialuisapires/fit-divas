using System.Security.Claims;
using FitDivas.Application.DTOs.Weight;
using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/weight")]
[Authorize]
public class WeightController(IWeightService weightService) : ControllerBase
{
    [HttpPost("goal")]
    public async Task<IActionResult> CreateGoal([FromBody] CreateWeightGoalDto dto) =>
        Ok(await weightService.CreateGoalAsync(GetUserId(), dto));

    [HttpGet("goal/active")]
    public async Task<IActionResult> GetActiveGoal() =>
        Ok(await weightService.GetActiveGoalAsync(GetUserId()));

    [HttpGet("goal/history")]
    public async Task<IActionResult> GetGoalHistory() =>
        Ok(await weightService.GetGoalHistoryAsync(GetUserId()));

    [HttpPost]
    public async Task<IActionResult> AddWeight([FromBody] AddWeightDto dto) =>
        Ok(await weightService.AddWeightAsync(GetUserId(), dto));

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
