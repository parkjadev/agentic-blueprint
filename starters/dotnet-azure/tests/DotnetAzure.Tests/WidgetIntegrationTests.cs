using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using DotnetAzure.Api.Data;
using DotnetAzure.Tests.Fixtures;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Testcontainers.PostgreSql;
using Xunit;

namespace DotnetAzure.Tests;

/// <summary>Integration tests that exercise the full EF Core migration +
/// CRUD path against a real PostgreSQL instance started via Testcontainers.
/// Tagged `Category=Integration` so the clean-boot `dotnet test` filter can
/// exclude them when Docker is unavailable (CI runs them separately, see
/// `starter-verify` skill and the starter README).</summary>
[Trait("Category", "Integration")]
public sealed class WidgetIntegrationTests : IAsyncLifetime
{
    private const string Alice = "alice-oid-00000000-0000-0000-0000-000000000001";
    private const string Bob = "bob-oid-00000000-0000-0000-0000-000000000002";

    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder()
        .WithImage("postgres:16-alpine")
        .WithDatabase("appdb")
        .WithUsername("postgres")
        .WithPassword("dev")
        .Build();

    private TestWebApplicationFactory? _factory;

    public async ValueTask InitializeAsync()
    {
        await _postgres.StartAsync();

        _factory = new TestWebApplicationFactory().UseNpgsql(_postgres.GetConnectionString());

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.MigrateAsync();
    }

    public async ValueTask DisposeAsync()
    {
        if (_factory is not null)
        {
            await _factory.DisposeAsync();
        }
        await _postgres.DisposeAsync();
    }

    [Fact]
    public async Task Migration_runs_against_fresh_postgres()
    {
        Assert.NotNull(_factory);
        using var scope = _factory!.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var applied = await db.Database.GetAppliedMigrationsAsync();
        Assert.Contains(applied, m => m.EndsWith("_InitialCreate", StringComparison.Ordinal));
    }

    [Fact]
    public async Task Widget_crud_roundtrips_through_real_postgres()
    {
        Assert.NotNull(_factory);
        using var client = _factory!.CreateClientFor(Alice);

        // create
        var created = await client.PostAsJsonAsync("/api/widgets", new
        {
            name = "Gamma",
            description = "integration-test",
        });
        Assert.Equal(HttpStatusCode.Created, created.StatusCode);
        var widget = await created.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.NotNull(widget?.Data);
        var id = widget!.Data!.Id;

        // read
        var fetched = await client.GetAsync($"/api/widgets/{id}");
        Assert.Equal(HttpStatusCode.OK, fetched.StatusCode);

        // update
        var patched = await client.PatchAsJsonAsync($"/api/widgets/{id}", new
        {
            description = "integration-test (updated)",
        });
        Assert.Equal(HttpStatusCode.OK, patched.StatusCode);

        // list — should contain our widget
        var list = await client.GetFromJsonAsync<Envelope<WidgetDto[]>>("/api/widgets", JsonOptions);
        Assert.NotNull(list?.Data);
        Assert.Contains(list!.Data!, w => w.Id == id);

        // delete
        var deleted = await client.DeleteAsync($"/api/widgets/{id}");
        Assert.Equal(HttpStatusCode.NoContent, deleted.StatusCode);

        // confirm 404 after delete
        var missing = await client.GetAsync($"/api/widgets/{id}");
        Assert.Equal(HttpStatusCode.NotFound, missing.StatusCode);
    }

    [Fact]
    public async Task Ownership_enforced_across_real_postgres_connections()
    {
        Assert.NotNull(_factory);
        using var alice = _factory!.CreateClientFor(Alice);
        using var bob = _factory.CreateClientFor(Bob);

        var created = await alice.PostAsJsonAsync("/api/widgets", new { name = "Alice-owned" });
        var widget = await created.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.NotNull(widget?.Data);
        var id = widget!.Data!.Id;

        var bobRead = await bob.GetAsync($"/api/widgets/{id}");
        Assert.Equal(HttpStatusCode.Forbidden, bobRead.StatusCode);

        var bobPatch = await bob.PatchAsJsonAsync($"/api/widgets/{id}", new { name = "hijacked" });
        Assert.Equal(HttpStatusCode.Forbidden, bobPatch.StatusCode);

        var bobDelete = await bob.DeleteAsync($"/api/widgets/{id}");
        Assert.Equal(HttpStatusCode.Forbidden, bobDelete.StatusCode);
    }

    private sealed record Envelope<T>(bool Success, T? Data, ErrorBody? Error);

    private sealed record ErrorBody(string Code, string Message);

    private sealed record WidgetDto(Guid Id, string Name, string? Description, string OwnerId, string Status);
}
