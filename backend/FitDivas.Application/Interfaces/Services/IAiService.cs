using FitDivas.Application.DTOs.AI;

namespace FitDivas.Application.Interfaces.Services;

public interface IAiService
{
    Task<AiChatResponseDto> ChatAsync(AiChatRequestDto dto);
}
