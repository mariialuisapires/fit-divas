namespace FitDivas.Application.DTOs.Challenge;

public class CreateChallengeDto
{
    public string Nome { get; set; } = string.Empty;
    public decimal? PesoInicial { get; set; }
    public decimal? PesoMeta { get; set; }
    public int MetaDiasTreinados { get; set; }
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }
}
