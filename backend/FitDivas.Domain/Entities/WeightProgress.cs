namespace FitDivas.Domain.Entities;

public class WeightProgress
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public decimal Peso { get; set; }
    public DateTime DataRegistro { get; set; }

    public User User { get; set; } = null!;
}
