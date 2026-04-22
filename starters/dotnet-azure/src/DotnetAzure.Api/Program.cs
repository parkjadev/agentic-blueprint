using DotnetAzure.Api;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

// Health endpoint — no auth, no database. Used by Container Apps liveness
// probes and the GitHub Actions smoke test. Every deploy verifies this
// returns 200 before being considered successful.
app.MapGet("/health", () =>
    Results.Ok(ApiResponse.Ok(new HealthStatus("healthy", DateTimeOffset.UtcNow))));

app.Run();

internal sealed record HealthStatus(string Status, DateTimeOffset CheckedAt);

// Expose Program so WebApplicationFactory<Program> can spin it up in tests.
public partial class Program;
