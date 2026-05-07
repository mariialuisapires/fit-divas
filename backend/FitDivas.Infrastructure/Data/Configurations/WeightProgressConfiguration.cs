using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class WeightProgressConfiguration : IEntityTypeConfiguration<WeightProgress>
{
    public void Configure(EntityTypeBuilder<WeightProgress> builder)
    {
        builder.ToTable("weight_progresses");
        builder.HasKey(w => w.Id);
        builder.Property(w => w.Id).HasColumnName("id");
        builder.Property(w => w.UserId).HasColumnName("user_id");
        builder.Property(w => w.Peso).HasColumnName("peso").HasPrecision(5, 2);
        builder.Property(w => w.DataRegistro).HasColumnName("data_registro");

        builder.HasOne(w => w.User)
            .WithMany(u => u.ProgressoPeso)
            .HasForeignKey(w => w.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
