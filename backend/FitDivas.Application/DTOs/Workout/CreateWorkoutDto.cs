namespace FitDivas.Application.DTOs.Workout;

public class CreateWorkoutDto
{
    public string Nome { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
    public string? DiaSemana { get; set; }
    public List<CreateExerciseDto> Exercicios { get; set; } = [];
}

public class CreateExerciseDto
{
    public string Nome { get; set; } = string.Empty;
    public int Series { get; set; }
    public int Repeticoes { get; set; }
    public decimal? Carga { get; set; }
    public string? Observacoes { get; set; }
    public int Ordem { get; set; }
}
