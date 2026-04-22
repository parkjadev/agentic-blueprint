namespace DotnetAzure.Api.Data.Entities;

/// <summary>Lifecycle state for a widget. Persisted as a string so new values
/// are forward-compatible without migration when the enum grows.</summary>
public enum WidgetStatus
{
    Active,
    Archived,
    Deleted,
}
