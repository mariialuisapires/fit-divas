using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class WeightGoalConfiguration : IEntityTypeConfiguration<WeightGoal>
{
    public void Configure(EntityTypeBuilder<WeightGoal> builder)
    {
        builder.ToTable("weight_goals");
        builder.HasKey(g => g.Id);
        builder.Property(g => g.Id).HasColumnName("id");
        builder.Property(g => g.UserId).HasColumnName("user_id");
        builder.Property(g => g.PesoInicial).HasColumnName("peso_inicial").HasColumnType("numeric(5,2)");
        builder.Property(g => g.PesoMeta).HasColumnName("peso_meta").HasColumnType("numeric(5,2)");
        builder.Property(g => g.Tipo).HasColumnName("tipo").HasMaxLength(10);
        builder.Property(g => g.DataInicio).HasColumnName("data_inicio");
        builder.Property(g => g.DataFim).HasColumnName("data_fim");
        builder.Property(g => g.Status).HasColumnName("status").HasMaxLength(20).HasDefaultValue("ativo");

        builder.HasOne(g => g.User)
            .WithMany()
            .HasForeignKey(g => g.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(g => new { g.UserId, g.Status });
    }
}
