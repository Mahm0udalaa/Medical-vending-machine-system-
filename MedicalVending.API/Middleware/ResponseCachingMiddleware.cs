using Microsoft.AspNetCore.ResponseCaching;

namespace MedicalVending.API.Middleware
{
    public class ResponseCachingMiddleware
    {
        public static void ConfigureResponseCaching(IServiceCollection services)
        {
            services.AddResponseCaching(options =>
            {
                options.MaximumBodySize = 64 * 1024 * 1024; // 64 MB
                options.UseCaseSensitivePaths = false;
            });

            services.AddMemoryCache();
        }

        public static void UseResponseCaching(IApplicationBuilder app)
        {
            app.UseResponseCaching();
        }
    }
} 