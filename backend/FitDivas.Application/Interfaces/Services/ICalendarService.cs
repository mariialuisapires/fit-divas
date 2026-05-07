using FitDivas.Application.DTOs.Calendar;

namespace FitDivas.Application.Interfaces.Services;

public interface ICalendarService
{
    Task<CalendarMonthDto> GetMonthAsync(Guid userId, int year, int month);
}
