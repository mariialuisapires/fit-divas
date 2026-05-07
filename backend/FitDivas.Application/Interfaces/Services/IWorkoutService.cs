using FitDivas.Application.DTOs.Workout;

namespace FitDivas.Application.Interfaces.Services;

public interface IWorkoutService
{
    Task<List<WorkoutResponseDto>> GetAllAsync(Guid userId);
    Task<WorkoutResponseDto> GetByIdAsync(Guid id, Guid userId);
    Task<WorkoutResponseDto> CreateAsync(Guid userId, CreateWorkoutDto dto);
    Task<WorkoutResponseDto> UpdateAsync(Guid id, Guid userId, UpdateWorkoutDto dto);
    Task DeleteAsync(Guid id, Guid userId);
    Task CompleteWorkoutAsync(Guid workoutId, Guid userId);
}
