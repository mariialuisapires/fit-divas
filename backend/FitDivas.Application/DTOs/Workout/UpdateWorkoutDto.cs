namespace FitDivas.Application.DTOs.Workout;

public class UpdateWorkoutDto
{
    public string? Nome { get; set; }
    public string? Observacoes { get; set; }
    public List<UpdateExerciseDto>? Exercicios { get; set; }
}

public class UpdateExerciseDto
{
    public Guid? Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public int Series { get; set; }
    public int Repeticoes { get; set; }
    public decimal? Carga { get; set; }
    public string? Observacoes { get; set; }
    public int Ordem { get; set; }
}
