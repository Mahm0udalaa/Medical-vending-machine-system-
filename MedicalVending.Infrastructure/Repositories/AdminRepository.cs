using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using MedicalVending.Domain.Exceptions;

namespace MedicalVending.Infrastructure.Repositories
{
    public class AdminRepository : BaseRepository, IAdminRepository
    {
        public AdminRepository(ApplicationDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<Admin>> GetAllAsync()
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Admins.ToListAsync(),
                "Error retrieving all admins");
        }

        public async Task<Admin?> GetByIdAsync(int id)
        {
            return await ExecuteSafelyAsync(async () =>
            {
                var admin = await _context.Admins.FindAsync(id);
                if (admin == null)
                {
                    throw new NotFoundException("Admin", id);
                }
                return admin;
            }, $"Error retrieving admin with ID {id}");
        }

        public async Task AddAsync(Admin admin)
        {
            await ExecuteSafelyAsync(async () =>
            {
                await _context.Admins.AddAsync(admin);
                await _context.SaveChangesAsync();
            }, "Error adding admin");
        }

        public async Task UpdateAsync(Admin admin)
        {
            await ExecuteSafelyAsync(async () =>
            {
                // Check if the entity exists
                await EnsureEntityExistsAsync<Admin>(admin.AdminId, ExistsAsync, "Admin");
                
                _context.Admins.Update(admin);
                await _context.SaveChangesAsync();
            }, $"Error updating admin with ID {admin.AdminId}");
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Admins.AnyAsync(a => a.AdminId == id),
                $"Error checking admin existence with ID {id}");
        }

        public async Task DeleteAsync(int id)
        {
            await ExecuteSafelyAsync(async () =>
            {
                var admin = await _context.Admins.FindAsync(id);
                if (admin != null)
                {
                    _context.Admins.Remove(admin);
                    await _context.SaveChangesAsync();
                }
                else
                {
                    throw new NotFoundException("Admin", id);
                }
            }, $"Error deleting admin with ID {id}");
        }

        public async Task<Admin?> GetByEmailAsync(string email)
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Admins.FirstOrDefaultAsync(a => a.AdminEmail == email),
                $"Error retrieving admin with email {email}");
        }
    }
}
