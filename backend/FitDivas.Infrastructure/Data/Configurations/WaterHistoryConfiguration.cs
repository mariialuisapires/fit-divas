using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class WaterHistoryConfiguration : IEntityTypeConfiguration<WaterHistory>
{
    public void Configure(EntityTypeBuilder<WaterHistory> builder)
    {
        builder.ToTable("water_histories");
        builder.HasKey(h => h.Id);
        builder.Property(h => h.Id).HasColumnName("id");
        builder.Property(h => h.UserId).HasColumnName("user_id");
        builder.Property(h => h.QuantidadeMl).HasColumnName("quantidade_ml");
        builder.Property(h => h.DataRegistro).HasColumnName("data_registro");

        builder.HasOne(h => h.User)
            .WithMany(u => u.HistoricoAgua)
            .HasForeignKey(h => h.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
