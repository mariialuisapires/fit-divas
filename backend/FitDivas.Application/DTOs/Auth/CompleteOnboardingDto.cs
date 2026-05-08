namespace FitDivas.Application.DTOs.Auth;

public class CompleteOnboardingDto
{
    public string Genero { get; set; } = string.Empty;
    public string Objetivo { get; set; } = string.Empty;
    public int Idade { get; set; }
    public decimal Altura { get; set; }
    public decimal PesoAtual { get; set; }
    public decimal PesoMeta { get; set; }
}
