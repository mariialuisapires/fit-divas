namespace FitDivas.Application.DTOs.Workout;

public class WorkoutResponseDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
    public DateTime CriadoEm { get; set; }
    public List<ExerciseResponseDto> Exercicios { get; set; } = [];
}

public class ExerciseResponseDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public int Series { get; set; }
    public int Repeticoes { get; set; }
    public decimal? Carga { get; set; }
    public string? Observacoes { get; set; }
    public int Ordem { get; set; }
}
