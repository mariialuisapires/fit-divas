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
    [HttpGet]
    public async Task<IActionResult> GetSummary() =>
        Ok(await weightService.GetSummaryAsync(GetUserId()));

    [HttpPost]
    public async Task<IActionResult> AddWeight([FromBody] AddWeightDto dto) =>
        Ok(await weightService.AddWeightAsync(GetUserId(), dto));

    [HttpGet("history")]
    public async Task<IActionResult> GetHistory([FromQuery] int year = 0, [FromQuery] int month = 0)
    {
        var now = DateTime.UtcNow;
        return Ok(await weightService.GetMonthlyHistoryAsync(
            GetUserId(),
            year > 0 ? year : now.Year,
            month > 0 ? month : now.Month));
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
