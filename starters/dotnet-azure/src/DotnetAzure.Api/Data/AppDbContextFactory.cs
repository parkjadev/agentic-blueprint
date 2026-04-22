using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace DotnetAzure.Api.Data;

/// <summary>Design-time factory used by `dotnet ef` tooling. Runtime
/// construction goes through the regular DI pipeline in Program.cs; this
/// factory only runs when the EF CLI needs a DbContext instance for
/// migration scaffolding.</summary>
public sealed class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__AppDb")
            ?? "Host=localhost;Port=5432;Database=appdb;Username=postgres;Password=dev";

        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(connectionString)
            .Options;

        return new AppDbContext(options);
    }
}
