using MedicalVending.Domain.Exceptions;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public abstract class BaseRepository
    {
        protected readonly ApplicationDbContext _context;

        protected BaseRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Executes a database operation with exception handling
        /// </summary>
        protected async Task ExecuteSafelyAsync(Func<Task> operation, string errorMessage = "An error occurred while accessing the database")
        {
            try
            {
                await operation();
            }
            catch (DbUpdateConcurrencyException ex)
            {
                throw new ConflictException($"{errorMessage}: Concurrency conflict", ex);
            }
            catch (DbUpdateException ex)
            {
                if (ex.InnerException?.Message.Contains("duplicate") == true ||
                    ex.InnerException?.Message.Contains("unique constraint") == true ||
                    ex.InnerException?.Message.Contains("UNIQUE constraint") == true)
                {
                    throw new ConflictException($"{errorMessage}: The record already exists", ex);
                }

                throw new BadRequestException($"{errorMessage}: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                // Log the exception here if you have a logger
                throw new Exception($"{errorMessage}: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Executes a database operation with exception handling and returns a value
        /// </summary>
        protected async Task<T> ExecuteSafelyAsync<T>(Func<Task<T>> operation, string errorMessage = "An error occurred while accessing the database")
        {
            try
            {
                return await operation();
            }
            catch (DbUpdateConcurrencyException ex)
            {
                throw new ConflictException($"{errorMessage}: Concurrency conflict", ex);
            }
            catch (DbUpdateException ex)
            {
                if (ex.InnerException?.Message.Contains("duplicate") == true ||
                    ex.InnerException?.Message.Contains("unique constraint") == true ||
                    ex.InnerException?.Message.Contains("UNIQUE constraint") == true)
                {
                    throw new ConflictException($"{errorMessage}: The record already exists", ex);
                }

                throw new BadRequestException($"{errorMessage}: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                // Log the exception here if you have a logger
                throw new Exception($"{errorMessage}: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Check if entity exists by id and throw NotFoundException if not found
        /// </summary>
        protected async Task EnsureEntityExistsAsync<T>(int id, Func<int, Task<bool>> existsFunc, string entityName)
        {
            if (!await existsFunc(id))
            {
                throw new NotFoundException(entityName, id);
            }
        }
    }
} 