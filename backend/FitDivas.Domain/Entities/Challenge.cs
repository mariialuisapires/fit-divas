namespace FitDivas.Domain.Entities;

public class Challenge
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Nome { get; set; } = string.Empty;
    public decimal? PesoInicial { get; set; }
    public decimal? PesoMeta { get; set; }
    public int MetaDiasTreinados { get; set; }
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }
    public ChallengeStatus Status { get; set; } = ChallengeStatus.Ativo;

    public User User { get; set; } = null!;
}

public enum ChallengeStatus
{
    Ativo,
    Concluido,
    Cancelado
}
