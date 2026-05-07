namespace FitDivas.Domain.Entities;

public class Exercise
{
    public Guid Id { get; set; }
    public Guid WorkoutId { get; set; }
    public string Nome { get; set; } = string.Empty;
    public int Series { get; set; }
    public int Repeticoes { get; set; }
    public decimal? Carga { get; set; }
    public string? Observacoes { get; set; }
    public int Ordem { get; set; }

    public Workout Workout { get; set; } = null!;
}
