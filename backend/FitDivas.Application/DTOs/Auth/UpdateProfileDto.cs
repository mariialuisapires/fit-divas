namespace FitDivas.Application.DTOs.Auth;

public class UpdateProfileDto
{
    public string? Nome { get; set; }
    public decimal? PesoAtual { get; set; }
    public decimal? PesoMeta { get; set; }
    public decimal? Altura { get; set; }
    public string? FcmToken { get; set; }
    public int? MetaAguaMl { get; set; }
}
