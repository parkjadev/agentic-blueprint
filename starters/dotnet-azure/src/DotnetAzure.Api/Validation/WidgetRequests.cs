using System.ComponentModel.DataAnnotations;

namespace DotnetAzure.Api.Validation;

public sealed record CreateWidgetRequest(
    [property: Required, MaxLength(255)] string Name,
    [property: MaxLength(1000)] string? Description);

public sealed record UpdateWidgetRequest(
    [MaxLength(255)] string? Name,
    [MaxLength(1000)] string? Description,
    string? Status);
