using System.Security.Claims;
using FitDivas.Application.Interfaces.Repositories;

namespace FitDivas.API.Middleware;

public class ActiveUserMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context, IUserRepository userRepository)
    {
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var userIdStr = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdStr, out var userId))
            {
                var user = await userRepository.GetByIdAsync(userId);
                if (user == null || !user.IsActive)
                {
                    context.Response.StatusCode = 403;
                    context.Response.ContentType = "application/json";
                    await context.Response.WriteAsync("{\"error\":\"Conta bloqueada. Entre em contato com o suporte.\"}");
                    return;
                }
            }
        }
        await next(context);
    }
}
