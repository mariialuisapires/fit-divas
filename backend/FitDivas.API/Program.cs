using System.Text;
using FitDivas.API.Middleware;
using FitDivas.Domain.Entities;
using FitDivas.Infrastructure;
using FitDivas.Infrastructure.Data;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();

var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key não configurado.");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            RoleClaimType = System.Security.Claims.ClaimTypes.Role
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

var firebaseCredPath = builder.Configuration["Firebase:CredentialPath"];
if (!string.IsNullOrEmpty(firebaseCredPath) && File.Exists(firebaseCredPath))
{
    FirebaseApp.Create(new AppOptions
    {
        Credential = GoogleCredential.FromFile(firebaseCredPath)
    });
}

var app = builder.Build();

// Seed admin user
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<FitDivasDbContext>();
    await db.Database.MigrateAsync();

    var adminEmail = builder.Configuration["Admin:Email"] ?? "admin@fitdivas.com";
    var adminSenha = builder.Configuration["Admin:Senha"] ?? "Admin@2026!";

    if (!await db.Users.AnyAsync(u => u.Role == "admin"))
    {
        db.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            Nome = "Administrador",
            Email = adminEmail.ToLowerInvariant(),
            SenhaHash = BCrypt.Net.BCrypt.HashPassword(adminSenha),
            Role = "admin",
            IsActive = true,
            CriadoEm = DateTime.UtcNow
        });
        await db.SaveChangesAsync();
    }
}

app.UseMiddleware<ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();
app.UseMiddleware<ActiveUserMiddleware>();
app.MapControllers();

app.Run();
