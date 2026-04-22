using System.Net;
using System.Net.Http.Json;
using DotnetAzure.Tests.Fixtures;
using Xunit;

namespace DotnetAzure.Tests;

public sealed class HealthEndpointTests(TestWebApplicationFactory factory)
    : IClassFixture<TestWebApplicationFactory>
{
    [Fact]
    public async Task Get_health_returns_200_ok()
    {
        using var client = factory.CreateClient();

        var response = await client.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Get_health_body_uses_api_response_envelope()
    {
        using var client = factory.CreateClient();

        var body = await client.GetFromJsonAsync<HealthResponse>("/health");

        Assert.NotNull(body);
        Assert.True(body.Success);
        Assert.Null(body.Error);
        Assert.NotNull(body.Data);
        Assert.Equal("healthy", body.Data.Status);
    }

    private sealed record HealthResponse(bool Success, HealthData? Data, ErrorBody? Error);

    private sealed record HealthData(string Status, DateTimeOffset CheckedAt);

    private sealed record ErrorBody(string Code, string Message);
}
