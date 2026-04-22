namespace DotnetAzure.Api;

/// <summary>Envelope returned by every endpoint in this starter. Mirrors the
/// <c>{ success, data }</c> / <c>{ success, error }</c> shape used by the
/// sibling Next.js and Flutter starters. Do not bypass this envelope.</summary>
public sealed record ApiResponse<T>(bool Success, T? Data = default, ApiError? Error = null);

public sealed record ApiError(string Code, string Message);

/// <summary>Factory helpers for <see cref="ApiResponse{T}"/>. Kept on a
/// non-generic static type (instead of static members on the generic record)
/// so that <c>T</c> is inferred from the argument and CA1000 stays happy.</summary>
public static class ApiResponse
{
    public static ApiResponse<T> Ok<T>(T data) => new(true, data);

    public static ApiResponse<object?> Fail(string code, string message) =>
        new(false, Error: new ApiError(code, message));
}
