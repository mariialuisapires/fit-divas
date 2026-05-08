using FitDivas.Application.DTOs.Admin;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;

namespace FitDivas.Application.Services;

public class AdminService(IAdminRepository adminRepository, IUserRepository userRepository) : IAdminService
{
    public Task<DashboardStatsDto> GetDashboardStatsAsync() =>
        adminRepository.GetDashboardStatsAsync();

    public async Task<List<AdminUserDto>> GetUsersAsync()
    {
        var users = await adminRepository.GetAllUsersAsync();
        return users.Select(u => new AdminUserDto
        {
            Id = u.Id,
            Nome = u.Nome,
            Email = u.Email,
            IsActive = u.IsActive,
            CriadoEm = u.CriadoEm,
        }).ToList();
    }

    public async Task BlockUserAsync(Guid userId)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");
        if (user.Role == "admin")
            throw new InvalidOperationException("Não é possível bloquear um administrador.");
        user.IsActive = false;
        await userRepository.UpdateAsync(user);
    }

    public async Task UnblockUserAsync(Guid userId)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");
        user.IsActive = true;
        await userRepository.UpdateAsync(user);
    }

    public async Task DeleteUserAsync(Guid userId)
    {
        var user = await userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Usuária não encontrada.");
        if (user.Role == "admin")
            throw new InvalidOperationException("Não é possível remover um administrador.");
        await userRepository.DeleteAsync(user);
    }
}
