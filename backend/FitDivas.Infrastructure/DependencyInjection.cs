using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;
using FitDivas.Application.Services;
using FitDivas.Infrastructure.Data;
using FitDivas.Infrastructure.Repositories;
using FitDivas.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace FitDivas.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<FitDivasDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IWorkoutRepository, WorkoutRepository>();
        services.AddScoped<IWaterRepository, WaterRepository>();
        services.AddScoped<IChallengeRepository, ChallengeRepository>();
        services.AddScoped<IWeightRepository, WeightRepository>();
        services.AddScoped<IWeightGoalRepository, WeightGoalRepository>();
        services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
        services.AddScoped<IAdminRepository, AdminRepository>();

        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IAdminService, AdminService>();
        services.AddScoped<IWorkoutService, WorkoutService>();
        services.AddScoped<IWaterService, WaterService>();
        services.AddScoped<IChallengeService, ChallengeService>();
        services.AddScoped<IWeightService, WeightService>();
        services.AddScoped<ICalendarService, CalendarService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IAiService, AiService>();

        return services;
    }
}
