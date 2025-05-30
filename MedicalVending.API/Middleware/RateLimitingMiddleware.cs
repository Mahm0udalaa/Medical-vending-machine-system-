using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Caching.Memory;

namespace MedicalVending.API.Middleware
{
    public class RateLimitingMiddleware
    {
        private static readonly IMemoryCache _cache = new MemoryCache(new MemoryCacheOptions());
        private static readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1);

        public static void ConfigureRateLimiting(IServiceCollection services)
        {
            services.AddRateLimiter(options =>
            {
                // Global rate limiting
                options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        partitionKey: context.User.Identity?.Name ?? context.Request.Headers.Host.ToString(),
                        factory: partition => new FixedWindowRateLimiterOptions
                        {
                            AutoReplenishment = true,
                            PermitLimit = 100,
                            Window = TimeSpan.FromMinutes(1)
                        }));

                // Specific endpoint rate limiting
                options.AddPolicy("login", httpContext =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        partitionKey: httpContext.Request.Headers.Host.ToString(),
                        factory: _ => new FixedWindowRateLimiterOptions
                        {
                            AutoReplenishment = true,
                            PermitLimit = 5,
                            Window = TimeSpan.FromMinutes(1)
                        }));

                options.AddPolicy("register", httpContext =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        partitionKey: httpContext.Request.Headers.Host.ToString(),
                        factory: _ => new FixedWindowRateLimiterOptions
                        {
                            AutoReplenishment = true,
                            PermitLimit = 3,
                            Window = TimeSpan.FromMinutes(5)
                        }));

                options.OnRejected = async (context, token) =>
                {
                    context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
                    
                    double? retryAfterSeconds = null;
                    if (context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter))
                    {
                        retryAfterSeconds = retryAfter.TotalSeconds;
                    }

                    await context.HttpContext.Response.WriteAsJsonAsync(new
                    {
                        error = "Too many requests. Please try again later.",
                        retryAfter = retryAfterSeconds
                    }, token);
                };
            });
        }
    }
} 