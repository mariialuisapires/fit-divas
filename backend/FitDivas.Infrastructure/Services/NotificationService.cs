using FitDivas.Application.Interfaces.Services;
using FirebaseAdmin.Messaging;
using Microsoft.Extensions.Logging;

namespace FitDivas.Infrastructure.Services;

public class NotificationService(ILogger<NotificationService> logger) : INotificationService
{
    public async Task SendWaterReminderAsync(string fcmToken, int metaMl, int consumidoMl)
    {
        try
        {
            var restante = metaMl - consumidoMl;
            var message = new Message
            {
                Token = fcmToken,
                Notification = new Notification
                {
                    Title = "Hidratação 💧",
                    Body = $"Lembre-se de beber água! Faltam {restante}ml para atingir sua meta diária."
                },
                Data = new Dictionary<string, string>
                {
                    { "tipo", "lembrete_agua" },
                    { "meta_ml", metaMl.ToString() },
                    { "consumido_ml", consumidoMl.ToString() }
                }
            };

            await FirebaseMessaging.DefaultInstance.SendAsync(message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Erro ao enviar notificação de água para token {Token}", fcmToken);
        }
    }
}
