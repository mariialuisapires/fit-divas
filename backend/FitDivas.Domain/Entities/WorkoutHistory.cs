namespace FitDivas.Domain.Entities;

public class WorkoutHistory
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid WorkoutId { get; set; }
    public DateTime DataConclusao { get; set; }

    public User User { get; set; } = null!;
    public Workout Workout { get; set; } = null!;
}
