using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface IPurchaseMedicineRepository
    {
       // Task<PurchaseMedicine?> GetByIdAsync(int purchaseId, int medicineId);
        Task<IEnumerable<PurchaseMedicine>> GetByPurchaseAsync(int purchaseId);
        //Task<bool> ExistsAsync(int purchaseId, int medicineId);
        //Task AddAsync(PurchaseMedicine purchaseMedicine);
        //Task UpdateAsync(PurchaseMedicine purchaseMedicine);
       // Task DeleteAsync(int purchaseId, int medicineId);
        Task AddRangeAsync(IEnumerable<PurchaseMedicine> items);
        Task<IEnumerable<int>> GetMedicineIdsForPurchaseAsync(int purchaseId);
    }
}

