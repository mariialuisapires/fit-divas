using FitDivas.Domain.Entities;

namespace FitDivas.Application.DTOs.Challenge;

public class ChallengeResponseDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public decimal? PesoInicial { get; set; }
    public decimal? PesoMeta { get; set; }
    public int MetaDiasTreinados { get; set; }
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }
    public ChallengeStatus Status { get; set; }
    public int DiasTreinados { get; set; }
    public int DiasTotais { get; set; }
    public double ProgressoPercentual { get; set; }
    public decimal? PesoAtual { get; set; }
}
