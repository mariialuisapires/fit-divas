namespace FitDivas.Application.DTOs.Auth;

public class UserProfileDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public decimal? PesoAtual { get; set; }
    public decimal? PesoMeta { get; set; }
    public decimal? Altura { get; set; }
    public string? Genero { get; set; }
    public string? Objetivo { get; set; }
    public int? Idade { get; set; }
    public int MetaAguaMl { get; set; }
}
