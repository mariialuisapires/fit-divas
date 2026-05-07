using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class ExerciseConfiguration : IEntityTypeConfiguration<Exercise>
{
    public void Configure(EntityTypeBuilder<Exercise> builder)
    {
        builder.ToTable("exercises");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).HasColumnName("id");
        builder.Property(e => e.WorkoutId).HasColumnName("workout_id");
        builder.Property(e => e.Nome).HasColumnName("nome").HasMaxLength(100).IsRequired();
        builder.Property(e => e.Series).HasColumnName("series");
        builder.Property(e => e.Repeticoes).HasColumnName("repeticoes");
        builder.Property(e => e.Carga).HasColumnName("carga").HasPrecision(6, 2);
        builder.Property(e => e.Observacoes).HasColumnName("observacoes");
        builder.Property(e => e.Ordem).HasColumnName("ordem");
    }
}
