using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class ChallengeConfiguration : IEntityTypeConfiguration<Challenge>
{
    public void Configure(EntityTypeBuilder<Challenge> builder)
    {
        builder.ToTable("challenges");
        builder.HasKey(c => c.Id);
        builder.Property(c => c.Id).HasColumnName("id");
        builder.Property(c => c.UserId).HasColumnName("user_id");
        builder.Property(c => c.Nome).HasColumnName("nome").HasMaxLength(100).IsRequired();
        builder.Property(c => c.PesoInicial).HasColumnName("peso_inicial").HasPrecision(5, 2);
        builder.Property(c => c.PesoMeta).HasColumnName("peso_meta").HasPrecision(5, 2);
        builder.Property(c => c.MetaDiasTreinados).HasColumnName("meta_dias_treinados");
        builder.Property(c => c.DataInicio).HasColumnName("data_inicio");
        builder.Property(c => c.DataFim).HasColumnName("data_fim");
        builder.Property(c => c.Status).HasColumnName("status").HasConversion<string>();

        builder.HasOne(c => c.User)
            .WithMany(u => u.Desafios)
            .HasForeignKey(c => c.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
