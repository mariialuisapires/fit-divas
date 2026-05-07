using FitDivas.Application.DTOs.AI;
using FitDivas.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitDivas.API.Controllers;

[ApiController]
[Route("api/ai")]
[Authorize]
public class AiController(IAiService aiService) : ControllerBase
{
    [HttpPost("chat")]
    public async Task<IActionResult> Chat([FromBody] AiChatRequestDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Pergunta))
            return BadRequest(new { error = "Pergunta não pode ser vazia." });

        var result = await aiService.ChatAsync(dto);
        return Ok(result);
    }
}
