namespace FitDivas.Domain.Entities;

public class Workout
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
    public string? DiaSemana { get; set; }
    public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public ICollection<Exercise> Exercicios { get; set; } = [];
    public ICollection<WorkoutHistory> Historico { get; set; } = [];
}
