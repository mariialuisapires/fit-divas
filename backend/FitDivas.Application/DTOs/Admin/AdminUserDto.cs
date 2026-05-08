namespace FitDivas.Application.DTOs.Admin;

public class AdminUserDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime CriadoEm { get; set; }
}

public class DashboardStatsDto
{
    public int TotalUsuarios { get; set; }
    public int UsuariosAtivos { get; set; }
    public int UsuariosBloqueados { get; set; }
    public int DesafiosAtivos { get; set; }
    public int TreinosConcluidos { get; set; }
    public int MetasAtivas { get; set; }
}
