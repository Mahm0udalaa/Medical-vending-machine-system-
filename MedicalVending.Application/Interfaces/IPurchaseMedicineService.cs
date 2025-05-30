using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{

    public interface IPurchaseMedicineService
    {
        // Required
        Task AddBulkItemsAsync(int purchaseId, List<CreatePurchaseMedicineRequest> items);
        Task<IEnumerable<PurchaseMedicineResponse>> GetItemsByPurchaseAsync(int purchaseId);

        //// Optional (only if needed)
        //Task RemoveItemAsync(int purchaseId, int medicineId);
    }
}
