using FitDivas.Application.DTOs.Calendar;
using FitDivas.Application.Interfaces.Repositories;
using FitDivas.Application.Interfaces.Services;

namespace FitDivas.Application.Services;

public class CalendarService(IWorkoutRepository workoutRepository) : ICalendarService
{
    public async Task<CalendarMonthDto> GetMonthAsync(Guid userId, int year, int month)
    {
        var history = await workoutRepository.GetHistoryByMonthAsync(userId, year, month);

        var daysInMonth = DateTime.DaysInMonth(year, month);
        var days = new List<CalendarDayDto>();

        for (int day = 1; day <= daysInMonth; day++)
        {
            var date = new DateTime(year, month, day);
            var dayHistory = history.Where(h => h.DataConclusao.Date == date).ToList();

            days.Add(new CalendarDayDto
            {
                Data = date,
                Treinado = dayHistory.Any(),
                TreinosRealizados = dayHistory.Select(h => h.Workout?.Nome ?? "Treino").ToList()
            });
        }

        return new CalendarMonthDto
        {
            Ano = year,
            Mes = month,
            TotalDiasTreinados = days.Count(d => d.Treinado),
            Dias = days
        };
    }
}
