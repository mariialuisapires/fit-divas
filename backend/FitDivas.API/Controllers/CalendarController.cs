using System.Security.Claims;
using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/calendar")]
[Authorize]
public class CalendarController(ICalendarService calendarService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetMonth([FromQuery] int year = 0, [FromQuery] int month = 0)
    {
        var now = DateTime.UtcNow;
        var result = await calendarService.GetMonthAsync(
            GetUserId(),
            year > 0 ? year : now.Year,
            month > 0 ? month : now.Month);
        return Ok(result);
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
