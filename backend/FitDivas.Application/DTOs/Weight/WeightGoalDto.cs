namespace FitDivas.Application.DTOs.Weight;

public class CreateWeightGoalDto
{
    public decimal PesoAtual { get; set; }
    public decimal PesoMeta { get; set; }
}

public class WeightGoalResponseDto
{
    public Guid Id { get; set; }
    public decimal PesoInicial { get; set; }
    public decimal PesoMeta { get; set; }
    public string Tipo { get; set; } = string.Empty;
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }
    public string Status { get; set; } = string.Empty;
    public decimal? UltimoPeso { get; set; }
    public decimal? DiferencaAtual { get; set; }
    public List<WeightProgressDto> Progressos { get; set; } = [];
}

public class WeightGoalHistoryItemDto
{
    public Guid Id { get; set; }
    public decimal PesoInicial { get; set; }
    public decimal PesoMeta { get; set; }
    public string Tipo { get; set; } = string.Empty;
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }
    public decimal? PesoFinal { get; set; }
    public string Resultado { get; set; } = string.Empty; // "atingida" | "nao_atingida"
}
