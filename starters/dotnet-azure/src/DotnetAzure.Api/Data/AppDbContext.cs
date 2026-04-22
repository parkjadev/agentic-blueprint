using DotnetAzure.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace DotnetAzure.Api.Data;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Widget> Widgets => Set<Widget>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Widget>(entity =>
        {
            entity.ToTable("Widgets");
            entity.HasKey(w => w.Id);
            entity.Property(w => w.Id).ValueGeneratedNever();
            entity.Property(w => w.Name).IsRequired().HasMaxLength(255);
            entity.Property(w => w.Description).HasMaxLength(1000);
            entity.Property(w => w.OwnerId).IsRequired().HasMaxLength(255);
            entity.Property(w => w.Status)
                .HasConversion<string>()
                .HasMaxLength(16)
                .IsRequired();
            entity.Property(w => w.CreatedAt).IsRequired();
            entity.Property(w => w.UpdatedAt).IsRequired();
            entity.HasIndex(w => w.OwnerId);
        });
    }
}
