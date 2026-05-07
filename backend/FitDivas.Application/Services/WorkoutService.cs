using FitDivas.Application.DTOs.Workout;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;
using FitDivas.Domain.Entities;

namespace FitDivas.Application.Services;

public class WorkoutService(IWorkoutRepository workoutRepository) : IWorkoutService
{
    public async Task<List<WorkoutResponseDto>> GetAllAsync(Guid userId)
    {
        var workouts = await workoutRepository.GetAllByUserAsync(userId);
        return workouts.Select(MapToDto).ToList();
    }

    public async Task<WorkoutResponseDto> GetByIdAsync(Guid id, Guid userId)
    {
        var workout = await workoutRepository.GetByIdAsync(id, userId)
            ?? throw new KeyNotFoundException("Treino não encontrado.");
        return MapToDto(workout);
    }

    public async Task<WorkoutResponseDto> CreateAsync(Guid userId, CreateWorkoutDto dto)
    {
        var workout = new Workout
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Nome = dto.Nome,
            Observacoes = dto.Observacoes,
            DiaSemana = dto.DiaSemana,
            Exercicios = dto.Exercicios.Select((e, i) => new Exercise
            {
                Id = Guid.NewGuid(),
                Nome = e.Nome,
                Series = e.Series,
                Repeticoes = e.Repeticoes,
                Carga = e.Carga,
                Observacoes = e.Observacoes,
                Ordem = e.Ordem > 0 ? e.Ordem : i + 1
            }).ToList()
        };

        await workoutRepository.CreateAsync(workout);
        return MapToDto(workout);
    }

    public async Task<WorkoutResponseDto> UpdateAsync(Guid id, Guid userId, UpdateWorkoutDto dto)
    {
        var workout = await workoutRepository.GetByIdAsync(id, userId)
            ?? throw new KeyNotFoundException("Treino não encontrado.");

        if (dto.Nome is not null) workout.Nome = dto.Nome;
        if (dto.Observacoes is not null) workout.Observacoes = dto.Observacoes;

        if (dto.Exercicios is not null)
        {
            workout.Exercicios = dto.Exercicios.Select((e, i) => new Exercise
            {
                Id = e.Id ?? Guid.NewGuid(),
                WorkoutId = workout.Id,
                Nome = e.Nome,
                Series = e.Series,
                Repeticoes = e.Repeticoes,
                Carga = e.Carga,
                Observacoes = e.Observacoes,
                Ordem = e.Ordem > 0 ? e.Ordem : i + 1
            }).ToList();
        }

        await workoutRepository.UpdateAsync(workout);
        return MapToDto(workout);
    }

    public async Task DeleteAsync(Guid id, Guid userId)
    {
        var workout = await workoutRepository.GetByIdAsync(id, userId)
            ?? throw new KeyNotFoundException("Treino não encontrado.");
        await workoutRepository.DeleteAsync(workout);
    }

    public async Task CompleteWorkoutAsync(Guid workoutId, Guid userId)
    {
        var workout = await workoutRepository.GetByIdAsync(workoutId, userId)
            ?? throw new KeyNotFoundException("Treino não encontrado.");

        var history = new WorkoutHistory
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            WorkoutId = workout.Id,
            DataConclusao = DateTime.UtcNow
        };

        await workoutRepository.AddHistoryAsync(history);
    }

    private static WorkoutResponseDto MapToDto(Workout w) => new()
    {
        Id = w.Id,
        Nome = w.Nome,
        Observacoes = w.Observacoes,
        DiaSemana = w.DiaSemana,
        CriadoEm = w.CriadoEm,
        Exercicios = w.Exercicios.OrderBy(e => e.Ordem).Select(e => new ExerciseResponseDto
        {
            Id = e.Id,
            Nome = e.Nome,
            Series = e.Series,
            Repeticoes = e.Repeticoes,
            Carga = e.Carga,
            Observacoes = e.Observacoes,
            Ordem = e.Ordem
        }).ToList()
    };
}
