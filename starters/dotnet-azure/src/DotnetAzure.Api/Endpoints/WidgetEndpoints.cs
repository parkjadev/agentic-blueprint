using System.Security.Claims;
using DotnetAzure.Api.Data;
using DotnetAzure.Api.Data.Entities;
using DotnetAzure.Api.Validation;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DotnetAzure.Api.Endpoints;

/// <summary>Widget CRUD endpoints. Every endpoint requires authentication;
/// ownership is enforced by comparing the `sub` claim on the JWT with the
/// `OwnerId` column. Responses always use the <see cref="ApiResponse{T}"/>
/// envelope.</summary>
public static class WidgetEndpoints
{
    public static IEndpointRouteBuilder MapWidgetEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/widgets").RequireAuthorization();

        group.MapGet("/", ListWidgets);
        group.MapPost("/", CreateWidget);
        group.MapGet("/{id:guid}", GetWidget);
        group.MapPatch("/{id:guid}", UpdateWidget);
        group.MapDelete("/{id:guid}", DeleteWidget);

        return app;
    }

    private static async Task<Ok<ApiResponse<IReadOnlyList<Widget>>>> ListWidgets(
        HttpContext http,
        AppDbContext db,
        CancellationToken ct)
    {
        var owner = RequireOwnerId(http);
        var widgets = await db.Widgets
            .Where(w => w.OwnerId == owner)
            .OrderByDescending(w => w.CreatedAt)
            .ToListAsync(ct);

        return TypedResults.Ok(ApiResponse.Ok<IReadOnlyList<Widget>>(widgets));
    }

    private static async Task<Results<Created<ApiResponse<Widget>>, BadRequest<ApiResponse<object?>>>> CreateWidget(
        HttpContext http,
        AppDbContext db,
        [FromBody] CreateWidgetRequest request,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return TypedResults.BadRequest(ApiResponse.Fail("VALIDATION_ERROR", "Name is required."));
        }

        var widget = new Widget
        {
            Name = request.Name.Trim(),
            Description = request.Description?.Trim(),
            OwnerId = RequireOwnerId(http),
        };

        db.Widgets.Add(widget);
        await db.SaveChangesAsync(ct);

        return TypedResults.Created($"/api/widgets/{widget.Id}", ApiResponse.Ok(widget));
    }

    private static async Task<Results<Ok<ApiResponse<Widget>>, NotFound<ApiResponse<object?>>, ForbidHttpResult>> GetWidget(
        HttpContext http,
        AppDbContext db,
        Guid id,
        CancellationToken ct)
    {
        var widget = await db.Widgets.FindAsync([id], ct);
        if (widget is null)
        {
            return TypedResults.NotFound(ApiResponse.Fail("NOT_FOUND", "Widget not found."));
        }

        if (widget.OwnerId != RequireOwnerId(http))
        {
            return TypedResults.Forbid();
        }

        return TypedResults.Ok(ApiResponse.Ok(widget));
    }

    private static async Task<Results<Ok<ApiResponse<Widget>>, NotFound<ApiResponse<object?>>, BadRequest<ApiResponse<object?>>, ForbidHttpResult>> UpdateWidget(
        HttpContext http,
        AppDbContext db,
        Guid id,
        [FromBody] UpdateWidgetRequest request,
        CancellationToken ct)
    {
        var widget = await db.Widgets.FindAsync([id], ct);
        if (widget is null)
        {
            return TypedResults.NotFound(ApiResponse.Fail("NOT_FOUND", "Widget not found."));
        }

        if (widget.OwnerId != RequireOwnerId(http))
        {
            return TypedResults.Forbid();
        }

        if (request.Name is not null)
        {
            if (string.IsNullOrWhiteSpace(request.Name) || request.Name.Length > 255)
            {
                return TypedResults.BadRequest(ApiResponse.Fail("VALIDATION_ERROR", "Name must be 1-255 characters."));
            }
            widget.Name = request.Name.Trim();
        }

        if (request.Description is not null)
        {
            if (request.Description.Length > 1000)
            {
                return TypedResults.BadRequest(ApiResponse.Fail("VALIDATION_ERROR", "Description must be 1000 characters or fewer."));
            }
            widget.Description = request.Description.Trim();
        }

        if (request.Status is not null)
        {
            if (!Enum.TryParse<WidgetStatus>(request.Status, ignoreCase: true, out var parsed))
            {
                return TypedResults.BadRequest(ApiResponse.Fail("VALIDATION_ERROR", "Status must be one of: Active, Archived, Deleted."));
            }
            widget.Status = parsed;
        }

        widget.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(ct);

        return TypedResults.Ok(ApiResponse.Ok(widget));
    }

    private static async Task<Results<NoContent, NotFound<ApiResponse<object?>>, ForbidHttpResult>> DeleteWidget(
        HttpContext http,
        AppDbContext db,
        Guid id,
        CancellationToken ct)
    {
        var widget = await db.Widgets.FindAsync([id], ct);
        if (widget is null)
        {
            return TypedResults.NotFound(ApiResponse.Fail("NOT_FOUND", "Widget not found."));
        }

        if (widget.OwnerId != RequireOwnerId(http))
        {
            return TypedResults.Forbid();
        }

        db.Widgets.Remove(widget);
        await db.SaveChangesAsync(ct);

        return TypedResults.NoContent();
    }

    /// <summary>Resolves the current user's stable identifier from the JWT.
    /// Entra tokens surface the object ID via the `oid` claim (mapped to
    /// <see cref="ClaimTypes.NameIdentifier"/> by `Microsoft.Identity.Web`)
    /// and the subject via `sub`. Ownership uses the object ID so a token
    /// refresh never changes identity.</summary>
    private static string RequireOwnerId(HttpContext http)
    {
        var owner = http.User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? http.User.FindFirstValue("oid")
            ?? http.User.FindFirstValue("sub");
        return owner ?? throw new InvalidOperationException(
            "Authenticated request is missing a stable identifier claim (NameIdentifier/oid/sub).");
    }
}
