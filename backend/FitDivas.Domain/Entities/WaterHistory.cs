namespace FitDivas.Domain.Entities;

public class WaterHistory
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public int QuantidadeMl { get; set; }
    public DateTime DataRegistro { get; set; }

    public User User { get; set; } = null!;
}
