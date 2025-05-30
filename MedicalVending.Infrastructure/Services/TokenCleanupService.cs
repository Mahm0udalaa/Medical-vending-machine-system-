using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using MedicalVending.Infrastructure.DataBase;
using MedicalVending.Domain.Entities;

namespace MedicalVending.Infrastructure.Services
{
    public class TokenCleanupService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<TokenCleanupService> _logger;
        private readonly TimeSpan _checkInterval = TimeSpan.FromDays(1); // Run once per day

        public TokenCleanupService(
            IServiceProvider serviceProvider,
            ILogger<TokenCleanupService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Token Cleanup Service is starting. Will run once per day.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                        
                        // Delete expired tokens
                        var expiredTokens = await dbContext.RefreshTokens
                            .Where(t => t.ExpiresAt < DateTime.UtcNow || t.IsRevoked || t.IsUsed)
                            .ToListAsync(stoppingToken);

                        if (expiredTokens.Any())
                        {
                            dbContext.RefreshTokens.RemoveRange(expiredTokens);
                            await dbContext.SaveChangesAsync(stoppingToken);
                            _logger.LogInformation("Token cleanup completed. Removed {Count} expired tokens", 
                                expiredTokens.Count);
                        }
                        else
                        {
                            _logger.LogInformation("Token cleanup completed. No expired tokens found.");
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while cleaning up expired tokens");
                }

                await Task.Delay(_checkInterval, stoppingToken);
            }
        }
    }
} 