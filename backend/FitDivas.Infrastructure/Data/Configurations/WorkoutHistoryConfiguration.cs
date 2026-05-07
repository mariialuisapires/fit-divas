using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class WorkoutHistoryConfiguration : IEntityTypeConfiguration<WorkoutHistory>
{
    public void Configure(EntityTypeBuilder<WorkoutHistory> builder)
    {
        builder.ToTable("workout_histories");
        builder.HasKey(h => h.Id);
        builder.Property(h => h.Id).HasColumnName("id");
        builder.Property(h => h.UserId).HasColumnName("user_id");
        builder.Property(h => h.WorkoutId).HasColumnName("workout_id");
        builder.Property(h => h.DataConclusao).HasColumnName("data_conclusao");

        builder.HasOne(h => h.User)
            .WithMany(u => u.HistoricoTreinos)
            .HasForeignKey(h => h.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(h => h.Workout)
            .WithMany(w => w.Historico)
            .HasForeignKey(h => h.WorkoutId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
