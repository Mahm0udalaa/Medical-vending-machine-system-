using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public class FavoritesMedicineRepository : IFavoritesMedicineRepository
    {
        private readonly ApplicationDbContext _context;

        public FavoritesMedicineRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<bool> ExistsAsync(int customerId, int medicineId)
        {
            return await _context.FavoritesMedicines
                .AnyAsync(fm => fm.CustomerId == customerId && fm.MedicineId == medicineId);
        }

        public async Task<IEnumerable<FavoritesMedicine>> GetAllAsync()
        {
            return await _context.FavoritesMedicines
                .AsNoTracking()
                .ToListAsync();
        }

        public async Task<FavoritesMedicine?> GetByIdAsync(int customerId, int medicineId)
        {
            return await _context.FavoritesMedicines
                .Include(fm => fm.Medicine)  // Eager load medicine data
                .Include(fm => fm.Customer)   // Eager load customer data
                .FirstOrDefaultAsync(fm => fm.CustomerId == customerId && fm.MedicineId == medicineId);
        }

        public async Task<IEnumerable<FavoritesMedicine>> GetFavoritesByCustomerAsync(int customerId)
        {
            return await _context.FavoritesMedicines
                .Where(fm => fm.CustomerId == customerId)
                .Include(fm => fm.Medicine)  // Load medicine details
                .AsNoTracking()
                .ToListAsync();
        }

        public async Task AddAsync(int customerId, int medicineId)
        {
            if (await ExistsAsync(customerId, medicineId))
                throw new InvalidOperationException("Favorite already exists");

            // Load required relationships
            var customer = await _context.Customers.FindAsync(customerId);
            var medicine = await _context.Medicines.FindAsync(medicineId);

            if (customer == null || medicine == null)
                throw new KeyNotFoundException("Customer or Medicine not found");
            await _context.FavoritesMedicines.AddAsync(new()
            {
                CustomerId = customerId,
                MedicineId = medicineId,
                Customer = customer,  // Set required navigation
                Medicine = medicine

            });
            await _context.SaveChangesAsync();
        }

        //public async Task UpdateAsync(FavoritesMedicine favoritesMedicine)
        //{
        //    //favoritesMedicine.UpdatedAt = DateTime.UtcNow;
        //    _context.FavoritesMedicines.Update(favoritesMedicine);
        //    await _context.SaveChangesAsync();
        //}

        public async Task RemoveAsync(int customerId, int medicineId)
         => await _context.FavoritesMedicines
             .Where(f => f.CustomerId == customerId && f.MedicineId == medicineId)
             .ExecuteDeleteAsync();

        public async Task<int> CountCustomerFavoritesAsync(int customerId)
        => await _context.FavoritesMedicines
            .CountAsync(f => f.CustomerId == customerId);
    }

}

