using System.Net;
using System.Text.Json;
using MedicalVending.Domain.Exceptions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace MedicalVending.API.Middleware
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception error)
            {
                _logger.LogError(error, "An unhandled exception occurred");
                
                var response = context.Response;
                response.ContentType = "application/json";

                var errorResponse = new ErrorResponse
                {
                    StatusCode = error switch
                    {
                        NotFoundException => (int)HttpStatusCode.NotFound,
                        UnauthorizedAccessException => (int)HttpStatusCode.Unauthorized,
                        BadRequestException => (int)HttpStatusCode.BadRequest,
                        ConflictException => (int)HttpStatusCode.Conflict,
                        _ => (int)HttpStatusCode.InternalServerError
                    },
                    Message = error.Message,
                    Details = error.InnerException?.Message
                };

                response.StatusCode = errorResponse.StatusCode;

                var result = JsonSerializer.Serialize(errorResponse);
                await response.WriteAsync(result);
            }
        }
    }

    public class ErrorResponse
    {
        public int StatusCode { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? Details { get; set; }
    }
} 