using FitDivas.Application.DTOs.Admin;
using FitDivas.Domain.Entities;

namespace FitDivas.Application.Interfaces.Repositories;

public interface IAdminRepository
{
    Task<List<User>> GetAllUsersAsync();
    Task<DashboardStatsDto> GetDashboardStatsAsync();
}
