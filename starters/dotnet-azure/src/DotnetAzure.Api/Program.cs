using DotnetAzure.Api;
using DotnetAzure.Api.Data;
using DotnetAzure.Api.Endpoints;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Web;

var builder = WebApplication.CreateBuilder(args);

// ─── Authentication — Microsoft Entra ID (JWT bearer) ────────────────────────
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));

builder.Services.AddAuthorization();

// ─── Database — EF Core over Postgres ────────────────────────────────────────
// Connection string comes from ConnectionStrings__AppDb env var in production
// (injected by compute.bicep from the Bicep outputs). Local dev uses the
// docker-compose Postgres declared in docker-compose.yml.
var connectionString = builder.Configuration.GetConnectionString("AppDb")
    ?? throw new InvalidOperationException(
        "ConnectionStrings__AppDb is not configured. Set the environment variable " +
        "or provide a value in appsettings.Development.json.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();

// Health endpoint — no auth, no database. Used by Container Apps liveness
// probes and the GitHub Actions smoke test. Every deploy verifies this
// returns 200 before being considered successful.
app.MapGet("/health", () =>
    Results.Ok(ApiResponse.Ok(new HealthStatus("healthy", DateTimeOffset.UtcNow))))
    .AllowAnonymous();

// Widget CRUD — requires a valid Entra JWT. Ownership is enforced inside
// each handler via the `sub` claim.
app.MapWidgetEndpoints();

app.Run();

internal sealed record HealthStatus(string Status, DateTimeOffset CheckedAt);

// Expose Program so WebApplicationFactory<Program> can spin it up in tests.
public partial class Program;
