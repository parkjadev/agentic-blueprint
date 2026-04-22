using System.ComponentModel.DataAnnotations;

namespace DotnetAzure.Api.Data.Entities;

/// <summary>Domain-neutral example resource. The starter uses `Widget` as a
/// placeholder so adopters can trace the end-to-end pattern (entity →
/// DbContext → endpoints → tests) without importing any business semantics.
/// Replace or delete this entity in your fork.</summary>
public sealed class Widget
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(255)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Description { get; set; }

    /// <summary>Entra object ID of the creator, sourced from the JWT `sub`
    /// claim. Ownership checks in the endpoint layer compare this value to
    /// `HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier)`.</summary>
    [Required]
    [MaxLength(255)]
    public string OwnerId { get; set; } = string.Empty;

    public WidgetStatus Status { get; set; } = WidgetStatus.Active;

    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;

    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
}
