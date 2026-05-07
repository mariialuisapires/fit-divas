namespace FitDivas.Application.DTOs.Calendar;

public class CalendarDayDto
{
    public DateTime Data { get; set; }
    public bool Treinado { get; set; }
    public List<string> TreinosRealizados { get; set; } = [];
}

public class CalendarMonthDto
{
    public int Ano { get; set; }
    public int Mes { get; set; }
    public int TotalDiasTreinados { get; set; }
    public List<CalendarDayDto> Dias { get; set; } = [];
}
