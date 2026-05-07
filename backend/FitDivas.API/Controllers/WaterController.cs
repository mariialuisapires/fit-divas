using System.Security.Claims;
using FitDivas.Application.DTOs.Water;
using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/water")]
[Authorize]
public class WaterController(IWaterService waterService) : ControllerBase
{
    [HttpGet("today")]
    public async Task<IActionResult> GetToday() =>
        Ok(await waterService.GetTodaySummaryAsync(GetUserId()));

    [HttpPost]
    public async Task<IActionResult> AddWater([FromBody] AddWaterDto dto) =>
        Ok(await waterService.AddWaterAsync(GetUserId(), dto));

    [HttpDelete("{entryId:guid}")]
    public async Task<IActionResult> RemoveEntry(Guid entryId)
    {
        await waterService.RemoveEntryAsync(entryId, GetUserId());
        return NoContent();
    }

    [HttpGet("history")]
    public async Task<IActionResult> GetHistory([FromQuery] int year = 0, [FromQuery] int month = 0)
    {
        var now = DateTime.UtcNow;
        var result = await waterService.GetMonthlyHistoryAsync(
            GetUserId(),
            year > 0 ? year : now.Year,
            month > 0 ? month : now.Month);
        return Ok(result);
    }

    [HttpPut("goal")]
    public async Task<IActionResult> SetGoal([FromBody] SetWaterGoalDto dto)
    {
        await waterService.SetGoalAsync(GetUserId(), dto);
        return Ok();
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
