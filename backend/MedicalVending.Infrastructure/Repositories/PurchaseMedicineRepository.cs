using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public class PurchaseMedicineRepository : IPurchaseMedicineRepository
    {
        private readonly ApplicationDbContext _context;

        public PurchaseMedicineRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        //public async Task<PurchaseMedicine?> GetByIdAsync(int purchaseId, int medicineId)
        //    => await _context.PurchaseMedicines
        //        .Include(pm => pm.Medicine)
        //        .Include(pm => pm.Purchase)
        //        .FirstOrDefaultAsync(pm =>
        //            pm.PurchaseId == purchaseId &&
        //            pm.MedicineId == medicineId);

        public async Task<IEnumerable<PurchaseMedicine>> GetByPurchaseAsync(int purchaseId)
            => await _context.PurchaseMedicines
                .Where(pm => pm.PurchaseId == purchaseId)
                .Include(pm => pm.Medicine)
                .AsNoTracking()
                .ToListAsync();

        public async Task<bool> ExistsAsync(int purchaseId, int medicineId)
            => await _context.PurchaseMedicines
                .AnyAsync(pm =>
                    pm.PurchaseId == purchaseId &&
                    pm.MedicineId == medicineId);

        //public async Task AddAsync(PurchaseMedicine purchaseMedicine)
        //{
        //    await _context.PurchaseMedicines.AddAsync(purchaseMedicine);
        //    await _context.SaveChangesAsync();
        //}

        //public async Task UpdateAsync(PurchaseMedicine purchaseMedicine)
        //{
        //    _context.PurchaseMedicines.Update(purchaseMedicine);
        //    await _context.SaveChangesAsync();
        //}

        //public async Task DeleteAsync(int purchaseId, int medicineId)
        //{
        //    await _context.PurchaseMedicines
        //        .Where(pm =>
        //            pm.PurchaseId == purchaseId &&
        //            pm.MedicineId == medicineId)
        //        .ExecuteDeleteAsync();
        //}
        public async Task<IEnumerable<int>> GetMedicineIdsForPurchaseAsync(int purchaseId)
        {
            return await _context.PurchaseMedicines
                .Where(pm => pm.PurchaseId == purchaseId)
                .Select(pm => pm.MedicineId)
                .ToListAsync();
        }

        public async Task AddRangeAsync(IEnumerable<PurchaseMedicine> items)
        {
            await _context.PurchaseMedicines.AddRangeAsync(items);
            await _context.SaveChangesAsync();
        }
    }
}
