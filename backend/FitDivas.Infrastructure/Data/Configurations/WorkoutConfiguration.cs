using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class WorkoutConfiguration : IEntityTypeConfiguration<Workout>
{
    public void Configure(EntityTypeBuilder<Workout> builder)
    {
        builder.ToTable("workouts");
        builder.HasKey(w => w.Id);
        builder.Property(w => w.Id).HasColumnName("id");
        builder.Property(w => w.UserId).HasColumnName("user_id");
        builder.Property(w => w.Nome).HasColumnName("nome").HasMaxLength(100).IsRequired();
        builder.Property(w => w.Observacoes).HasColumnName("observacoes");
        builder.Property(w => w.DiaSemana).HasColumnName("dia_semana").HasMaxLength(20);
        builder.Property(w => w.CriadoEm).HasColumnName("criado_em");

        builder.HasOne(w => w.User)
            .WithMany(u => u.Treinos)
            .HasForeignKey(w => w.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(w => w.Exercicios)
            .WithOne(e => e.Workout)
            .HasForeignKey(e => e.WorkoutId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
