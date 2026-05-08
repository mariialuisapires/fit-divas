using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "admin")]
public class AdminController(IAdminService adminService) : ControllerBase
{
    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard() =>
        Ok(await adminService.GetDashboardStatsAsync());

    [HttpGet("users")]
    public async Task<IActionResult> GetUsers() =>
        Ok(await adminService.GetUsersAsync());

    [HttpPut("users/{id}/block")]
    public async Task<IActionResult> BlockUser(Guid id)
    {
        await adminService.BlockUserAsync(id);
        return NoContent();
    }

    [HttpPut("users/{id}/unblock")]
    public async Task<IActionResult> UnblockUser(Guid id)
    {
        await adminService.UnblockUserAsync(id);
        return NoContent();
    }

    [HttpDelete("users/{id}")]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        await adminService.DeleteUserAsync(id);
        return NoContent();
    }
}
