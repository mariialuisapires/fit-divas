namespace FitDivas.Application.DTOs.Auth;

public class RegisterDto
{
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Senha { get; set; } = string.Empty;
    public decimal? PesoAtual { get; set; }
    public decimal? PesoMeta { get; set; }
    public decimal? Altura { get; set; }
}
