using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using DotnetAzure.Tests.Fixtures;
using Xunit;

namespace DotnetAzure.Tests;

public sealed class WidgetEndpointsTests : IClassFixture<TestWebApplicationFactory>
{
    private const string Alice = "alice-oid-00000000-0000-0000-0000-000000000001";
    private const string Bob = "bob-oid-00000000-0000-0000-0000-000000000002";

    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web)
    {
        PropertyNameCaseInsensitive = true,
        Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase) },
    };

    private readonly TestWebApplicationFactory _factory;

    public WidgetEndpointsTests(TestWebApplicationFactory factory) => _factory = factory;

    [Fact]
    public async Task Get_widgets_without_token_returns_401()
    {
        using var client = _factory.CreateClient();

        var response = await client.GetAsync("/api/widgets");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Get_health_without_token_returns_200()
    {
        using var client = _factory.CreateClient();

        var response = await client.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_then_get_roundtrips_an_owned_widget()
    {
        using var client = _factory.CreateClientFor(Alice);

        var created = await client.PostAsJsonAsync("/api/widgets", new
        {
            name = "Alpha",
            description = "the first one",
        });
        Assert.Equal(HttpStatusCode.Created, created.StatusCode);

        var createdBody = await created.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.NotNull(createdBody);
        Assert.True(createdBody!.Success);
        Assert.NotNull(createdBody.Data);
        Assert.Equal("Alpha", createdBody.Data!.Name);
        Assert.Equal(Alice, createdBody.Data.OwnerId);

        var fetched = await client.GetAsync($"/api/widgets/{createdBody.Data.Id}");
        Assert.Equal(HttpStatusCode.OK, fetched.StatusCode);

        var fetchedBody = await fetched.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.NotNull(fetchedBody);
        Assert.Equal(createdBody.Data.Id, fetchedBody!.Data!.Id);
    }

    [Fact]
    public async Task Get_other_owners_widget_returns_403()
    {
        using var alice = _factory.CreateClientFor(Alice);
        using var bob = _factory.CreateClientFor(Bob);

        var created = await alice.PostAsJsonAsync("/api/widgets", new { name = "Alice's widget" });
        var widget = await created.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.NotNull(widget?.Data);

        var response = await bob.GetAsync($"/api/widgets/{widget!.Data!.Id}");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Get_missing_widget_returns_404()
    {
        using var client = _factory.CreateClientFor(Alice);

        var response = await client.GetAsync($"/api/widgets/{Guid.NewGuid()}");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task Post_without_name_returns_400()
    {
        using var client = _factory.CreateClientFor(Alice);

        var response = await client.PostAsJsonAsync("/api/widgets", new { name = "" });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Patch_toggles_status_for_owner()
    {
        using var client = _factory.CreateClientFor(Alice);

        var created = await client.PostAsJsonAsync("/api/widgets", new { name = "Beta" });
        var widget = await created.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.NotNull(widget?.Data);

        var updated = await client.PatchAsJsonAsync($"/api/widgets/{widget!.Data!.Id}", new
        {
            status = "Archived",
        });

        Assert.Equal(HttpStatusCode.OK, updated.StatusCode);
        var body = await updated.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.Equal("Archived", body!.Data!.Status);
    }

    [Fact]
    public async Task Delete_for_non_owner_returns_403()
    {
        using var alice = _factory.CreateClientFor(Alice);
        using var bob = _factory.CreateClientFor(Bob);

        var created = await alice.PostAsJsonAsync("/api/widgets", new { name = "Shared" });
        var widget = await created.Content.ReadFromJsonAsync<Envelope<WidgetDto>>(JsonOptions);
        Assert.NotNull(widget?.Data);

        var response = await bob.DeleteAsync($"/api/widgets/{widget!.Data!.Id}");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    private sealed record Envelope<T>(bool Success, T? Data, ErrorBody? Error);

    private sealed record ErrorBody(string Code, string Message);

    private sealed record WidgetDto(Guid Id, string Name, string? Description, string OwnerId, string Status);
}
