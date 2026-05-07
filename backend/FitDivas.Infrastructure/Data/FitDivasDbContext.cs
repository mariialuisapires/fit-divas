using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FitDivas.Infrastructure.Data;

public class FitDivasDbContext(DbContextOptions<FitDivasDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Workout> Workouts => Set<Workout>();
    public DbSet<Exercise> Exercises => Set<Exercise>();
    public DbSet<WorkoutHistory> WorkoutHistories => Set<WorkoutHistory>();
    public DbSet<WaterHistory> WaterHistories => Set<WaterHistory>();
    public DbSet<Challenge> Challenges => Set<Challenge>();
    public DbSet<WeightProgress> WeightProgresses => Set<WeightProgress>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(FitDivasDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
