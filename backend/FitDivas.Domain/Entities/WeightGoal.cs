namespace FitDivas.Domain.Entities;

public class WeightGoal
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public decimal PesoInicial { get; set; }
    public decimal PesoMeta { get; set; }
    public string Tipo { get; set; } = string.Empty; // "perda" | "ganho"
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }
    public string Status { get; set; } = "ativo"; // "ativo" | "finalizado"

    public User User { get; set; } = null!;
}
