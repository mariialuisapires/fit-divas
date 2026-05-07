namespace FitDivas.Application.DTOs.AI;

public class AiMessageDto
{
    public string Role { get; set; } = string.Empty; // "user" | "assistant"
    public string Content { get; set; } = string.Empty;
}

public class AiContextoDto
{
    public string? Nome { get; set; }
    public string? Genero { get; set; }
    public int? Idade { get; set; }
    public int? AlturaCm { get; set; }
    public string? Objetivo { get; set; }
    public double? PesoAtual { get; set; }
    public double? PesoMeta { get; set; }
    public string? StatusProgresso { get; set; }
    public string? PrevisaoMeta { get; set; }
}

public class AiChatRequestDto
{
    public string Pergunta { get; set; } = string.Empty;
    public List<AiMessageDto> Historico { get; set; } = [];
    public AiContextoDto? Contexto { get; set; }
}

public class AiChatResponseDto
{
    public string Resposta { get; set; } = string.Empty;
}
