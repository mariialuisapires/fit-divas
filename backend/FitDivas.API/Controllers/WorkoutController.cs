using System.Security.Claims;
using FitDivas.Application.DTOs.Workout;
using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/workouts")]
[Authorize]
public class WorkoutController(IWorkoutService workoutService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await workoutService.GetAllAsync(GetUserId()));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id) =>
        Ok(await workoutService.GetByIdAsync(id, GetUserId()));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWorkoutDto dto)
    {
        var result = await workoutService.CreateAsync(GetUserId(), dto);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateWorkoutDto dto) =>
        Ok(await workoutService.UpdateAsync(id, GetUserId(), dto));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await workoutService.DeleteAsync(id, GetUserId());
        return NoContent();
    }

    [HttpPost("{id:guid}/complete")]
    public async Task<IActionResult> Complete(Guid id)
    {
        await workoutService.CompleteWorkoutAsync(id, GetUserId());
        return Ok(new { message = "Treino concluído com sucesso!" });
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
