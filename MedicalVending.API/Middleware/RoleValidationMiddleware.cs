using System.Security.Claims;
using System.Threading.Tasks;

namespace MedicalVending.API.Middleware
{
    public class RoleValidationMiddleware
    {
        private readonly RequestDelegate _next;

        public RoleValidationMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            if (context.User.Identity?.IsAuthenticated == true)
            {
                var roleClaim = context.User.FindFirst(ClaimTypes.Role);
                if (roleClaim == null || (roleClaim.Value != "Admin" && roleClaim.Value != "Customer"))
                {
                    context.Response.StatusCode = 401;
                    await context.Response.WriteAsync("Invalid or missing role claim");
                    return;
                }
            }
            await _next(context);
        }
    }
} 