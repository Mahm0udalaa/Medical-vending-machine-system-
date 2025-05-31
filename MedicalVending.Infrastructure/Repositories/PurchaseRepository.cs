using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public class PurchaseRepository : IPurchaseRepository
    {
        private readonly ApplicationDbContext _context;

        public PurchaseRepository(ApplicationDbContext context)
        {
            _context = context;
        }
        public async Task<bool> ExistsAsync(int id)
        => await _context.Purchases.AnyAsync(p => p.PurchaseId == id);

        public async Task<IEnumerable<Purchase>> GetAllAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _context.Purchases.AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(p => p.PurchaseDate >= fromDate);

            if (toDate.HasValue)
                query = query.Where(p => p.PurchaseDate <= toDate);

            return await query
                .Include(p => p.VendingMachine)
                .OrderByDescending(p => p.PurchaseDate)
                .ToListAsync();
        }

        public async Task<decimal> GetTotalRevenueAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _context.Purchases.AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(p => p.PurchaseDate >= fromDate);

            if (toDate.HasValue)
                query = query.Where(p => p.PurchaseDate <= toDate);

            return await query.SumAsync(p => p.TotalPrice);
        }

        public async Task<int> GetTotalSalesCountAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _context.Purchases.AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(p => p.PurchaseDate >= fromDate);

            if (toDate.HasValue)
                query = query.Where(p => p.PurchaseDate <= toDate);

            return await query.CountAsync();
        }

        public async Task<Purchase?> GetByIdAsync(int id)
        {
            return await _context.Purchases.FindAsync(id);
        }

        public async Task AddAsync(Purchase purchase)
        {
            await _context.Purchases.AddAsync(purchase);
            await _context.SaveChangesAsync();
        }
        public async Task<IEnumerable<Purchase>> GetByCustomerAsync(int customerId)
      => await _context.Purchases
          .Where(p => p.CustomerId == customerId) // Use direct CustomerId field
          .Include(p => p.VendingMachine) // Include machine data if needed
          .Include(p => p.PurchaseMedicines) // Include medicines if needed
          .ThenInclude(pm => pm.Medicine)
          .OrderByDescending(p => p.PurchaseDate)
          .AsNoTracking() // Recommended for read-only
          .ToListAsync();

        public async Task<IEnumerable<Purchase>> GetByMachineAsync(int machineId)
        => await _context.Purchases
            .Where(p => p.MachineId == machineId)
            .Include(p => p.Customer)
            .Include(p => p.PurchaseMedicines)
                .ThenInclude(pm => pm.Medicine)
            .OrderByDescending(p => p.PurchaseDate)
            .AsNoTracking()
            .ToListAsync();

        public async Task<IEnumerable<Purchase>> GetAllWithDetailsAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _context.Purchases.AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(p => p.PurchaseDate >= fromDate);

            if (toDate.HasValue)
                query = query.Where(p => p.PurchaseDate <= toDate);

            return await query
                .Include(p => p.Customer)
                .Include(p => p.VendingMachine)
                .Include(p => p.PurchaseMedicines)
                    .ThenInclude(pm => pm.Medicine)
                .OrderByDescending(p => p.PurchaseDate)
                .ToListAsync();
        }
    }
}
