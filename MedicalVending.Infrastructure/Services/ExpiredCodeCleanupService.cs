using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MedicalVending.Infrastructure.DataBase;

namespace MedicalVending.Infrastructure.Services
{
    public class ExpiredCodeCleanupService : IHostedService, IDisposable
    {
        private readonly ILogger<ExpiredCodeCleanupService> _logger;
        private readonly IServiceProvider _services;
        private Timer _timer;

        public ExpiredCodeCleanupService(
            ILogger<ExpiredCodeCleanupService> logger,
            IServiceProvider services)
        {
            _logger = logger;
            _services = services;
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Expired Code Cleanup Service is starting.");

            _timer = new Timer(DoCleanup, null, TimeSpan.Zero, 
                TimeSpan.FromHours(1));

            return Task.CompletedTask;
        }

        private async void DoCleanup(object state)
        {
            try
            {
                using var scope = _services.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

                var expiredCodes = await context.EmailVerificationCodes
                    .Where(e => e.ExpirationTime < DateTime.UtcNow)
                    .ToListAsync();

                if (expiredCodes.Any())
                {
                    context.EmailVerificationCodes.RemoveRange(expiredCodes);
                    await context.SaveChangesAsync();
                    _logger.LogInformation($"Cleaned up {expiredCodes.Count} expired verification codes.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while cleaning up expired verification codes.");
            }
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Expired Code Cleanup Service is stopping.");

            _timer?.Change(Timeout.Infinite, 0);

            return Task.CompletedTask;
        }

        public void Dispose()
        {
            _timer?.Dispose();
        }
    }
} 