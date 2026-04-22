namespace DotnetAzure.Api;

/// <summary>Envelope returned by every endpoint in this starter. Mirrors the
/// <c>{ success, data }</c> / <c>{ success, error }</c> shape used by the
/// sibling Next.js and Flutter starters. Do not bypass this envelope.</summary>
public sealed record ApiResponse<T>(bool Success, T? Data = default, ApiError? Error = null)
{
    public static ApiResponse<T> Ok(T data) => new(true, data);

    public static ApiResponse<T> Fail(string code, string message) =>
        new(false, Error: new ApiError(code, message));
}

public sealed record ApiError(string Code, string Message);
