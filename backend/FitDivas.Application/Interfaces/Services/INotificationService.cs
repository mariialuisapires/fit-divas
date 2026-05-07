namespace FitDivas.Application.Interfaces.Services;

public interface INotificationService
{
    Task SendWaterReminderAsync(string fcmToken, int metaMl, int consumidoMl);
}
