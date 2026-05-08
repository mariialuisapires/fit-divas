using FitDivas.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitDivas.Infrastructure.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        builder.HasKey(u => u.Id);
        builder.Property(u => u.Id).HasColumnName("id");
        builder.Property(u => u.Nome).HasColumnName("nome").HasMaxLength(100).IsRequired();
        builder.Property(u => u.Email).HasColumnName("email").HasMaxLength(200).IsRequired();
        builder.Property(u => u.SenhaHash).HasColumnName("senha_hash").IsRequired();
        builder.Property(u => u.PesoAtual).HasColumnName("peso_atual").HasPrecision(5, 2);
        builder.Property(u => u.PesoMeta).HasColumnName("peso_meta").HasPrecision(5, 2);
        builder.Property(u => u.Altura).HasColumnName("altura").HasPrecision(4, 2);
        builder.Property(u => u.FcmToken).HasColumnName("fcm_token");
        builder.Property(u => u.MetaAguaMl).HasColumnName("meta_agua_ml").HasDefaultValue(2000);
        builder.Property(u => u.Role).HasColumnName("role").HasMaxLength(10).HasDefaultValue("user");
        builder.Property(u => u.IsActive).HasColumnName("is_active").HasDefaultValue(true);
        builder.Property(u => u.CriadoEm).HasColumnName("criado_em");
        builder.HasIndex(u => u.Email).IsUnique();
    }
}
