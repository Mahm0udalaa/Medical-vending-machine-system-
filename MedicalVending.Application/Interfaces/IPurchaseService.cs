using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    

    public interface IPurchaseService
    {
        //Task<PurchaseDto> CheckoutAsync(CreatePurchaseDto dto);
        Task<PurchaseDto> GetPurchaseDetailsAsync(int id);
        Task<IEnumerable<PurchaseDto>> GetCustomerPurchasesAsync(int customerId);
        // No Update/Delete (purchases are immutable after creation)
        Task<IEnumerable<PurchaseDto>> GetAllPurchasesAsync(DateTime? fromDate = null, DateTime? toDate = null);
        Task<PurchaseStatsDto> GetPurchaseStatsAsync(DateTime? fromDate = null, DateTime? toDate = null);
        // Admin-specific purchase data
        Task<IEnumerable<AdminPurchaseDto>> GetAdminPurchaseReportAsync(DateTime? fromDate = null, DateTime? toDate = null);
        Task<PurchaseDto> CheckoutCartAsync(int customerId);
        // New method for getting machine purchases
        Task<IEnumerable<PurchaseDto>> GetMachinePurchasesAsync(int machineId);
    }
}
