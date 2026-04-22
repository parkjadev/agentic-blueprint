using DotnetAzure.Api.Data;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace DotnetAzure.Tests.Fixtures;

/// <summary>Test host that swaps the production database for EF Core's
/// in-memory provider (unit tests) and replaces the JWT bearer scheme
/// with <see cref="TestAuthHandler"/>. Integration tests point
/// <see cref="DbName"/> at a Testcontainers Postgres instance via
/// <see cref="UseNpgsql"/>.</summary>
public class TestWebApplicationFactory : WebApplicationFactory<Program>
{
    private string? _npgsqlConnectionString;

    public string DbName { get; } = $"dotazure-tests-{Guid.NewGuid()}";

    public TestWebApplicationFactory UseNpgsql(string connectionString)
    {
        _npgsqlConnectionString = connectionString;
        return this;
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        builder.ConfigureAppConfiguration((_, config) =>
        {
            var settings = new Dictionary<string, string?>
            {
                // Connection string is ignored when the in-memory provider
                // is active, but Program.cs asserts a non-null value so a
                // placeholder is supplied here.
                ["ConnectionStrings:AppDb"] = _npgsqlConnectionString ?? "Host=ignored;Database=ignored",
                ["AzureAd:TenantId"] = "00000000-0000-0000-0000-000000000001",
                ["AzureAd:ClientId"] = "00000000-0000-0000-0000-000000000002",
                ["AzureAd:Instance"] = "https://login.microsoftonline.com/",
                ["AzureAd:Audience"] = "api://00000000-0000-0000-0000-000000000002",
            };
            config.AddInMemoryCollection(settings);
        });

        builder.ConfigureTestServices(services =>
        {
            // Swap the real DbContext registration for either in-memory
            // (unit) or Testcontainers Postgres (integration) depending on
            // whether UseNpgsql was called.
            var dbContextDescriptor = services.Single(
                d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
            services.Remove(dbContextDescriptor);

            if (_npgsqlConnectionString is null)
            {
                services.AddDbContext<AppDbContext>(options =>
                    options.UseInMemoryDatabase(DbName));
            }
            else
            {
                services.AddDbContext<AppDbContext>(options =>
                    options.UseNpgsql(_npgsqlConnectionString));
            }

            // Replace Microsoft.Identity.Web's JWT bearer handler with the
            // test handler. Name collision with JwtBearerDefaults.AuthenticationScheme
            // is intentional — tests send the X-Test-User header; production
            // keeps sending a real bearer token.
            services
                .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>(
                    JwtBearerDefaults.AuthenticationScheme, _ => { });
        });
    }

    public HttpClient CreateClientFor(string userId)
    {
        var client = CreateClient();
        client.DefaultRequestHeaders.Add(TestAuthHandler.UserHeaderName, userId);
        return client;
    }
}
