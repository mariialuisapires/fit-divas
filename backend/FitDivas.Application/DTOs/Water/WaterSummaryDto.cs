namespace FitDivas.Application.DTOs.Water;

public class WaterSummaryDto
{
    public int TotalMlHoje { get; set; }
    public int MetaDiariaMl { get; set; }
    public double PercentualAtingido { get; set; }
    public bool MetaAtingida { get; set; }
    public List<WaterHistoryItemDto> RegistrosHoje { get; set; } = [];
}

public class WaterHistoryItemDto
{
    public Guid Id { get; set; }
    public int QuantidadeMl { get; set; }
    public DateTime DataRegistro { get; set; }
}

public class WaterMonthlyDto
{
    public DateTime Data { get; set; }
    public int TotalMl { get; set; }
    public int MetaMl { get; set; }
    public bool MetaAtingida { get; set; }
}
