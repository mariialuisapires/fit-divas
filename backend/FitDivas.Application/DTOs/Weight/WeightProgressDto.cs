namespace FitDivas.Application.DTOs.Weight;

public class WeightProgressDto
{
    public Guid Id { get; set; }
    public decimal Peso { get; set; }
    public DateTime DataRegistro { get; set; }
}

public class WeightSummaryDto
{
    public decimal? PesoInicial { get; set; }
    public decimal? PesoAtual { get; set; }
    public decimal? PesoMeta { get; set; }
    public decimal? Diferenca { get; set; }
    public List<WeightProgressDto> Historico { get; set; } = [];
}
