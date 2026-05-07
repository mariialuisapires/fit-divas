namespace FitDivas.Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string SenhaHash { get; set; } = string.Empty;
    public decimal? PesoAtual { get; set; }
    public decimal? PesoMeta { get; set; }
    public decimal? Altura { get; set; }
    public string? FcmToken { get; set; }
    public int MetaAguaMl { get; set; } = 2000;
    public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

    public ICollection<Workout> Treinos { get; set; } = [];
    public ICollection<WorkoutHistory> HistoricoTreinos { get; set; } = [];
    public ICollection<WaterHistory> HistoricoAgua { get; set; } = [];
    public ICollection<Challenge> Desafios { get; set; } = [];
    public ICollection<WeightProgress> ProgressoPeso { get; set; } = [];
}
