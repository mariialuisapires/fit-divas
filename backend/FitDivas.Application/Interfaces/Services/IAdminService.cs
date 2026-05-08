using FitDivas.Application.DTOs.Admin;

namespace FitDivas.Application.Interfaces.Services;

public interface IAdminService
{
    Task<DashboardStatsDto> GetDashboardStatsAsync();
    Task<List<AdminUserDto>> GetUsersAsync();
    Task BlockUserAsync(Guid userId);
    Task UnblockUserAsync(Guid userId);
    Task DeleteUserAsync(Guid userId);
}
