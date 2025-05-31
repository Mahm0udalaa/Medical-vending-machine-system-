using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface IPurchaseRepository
    {
        Task<bool> ExistsAsync(int id); // Added for validation
        
        Task<Purchase?> GetByIdAsync(int id);
        Task<IEnumerable<Purchase>> GetByCustomerAsync(int customerId); // New method
        Task<IEnumerable<Purchase>> GetByMachineAsync(int machineId); // New method for machine purchases
        Task AddAsync(Purchase purchase);
        // Remove Update/Delete since purchases are immutable

        // Admin-Specific Methods
        Task<IEnumerable<Purchase>> GetAllAsync(DateTime? fromDate = null, DateTime? toDate = null);
        Task<decimal> GetTotalRevenueAsync(DateTime? fromDate = null, DateTime? toDate = null);
        Task<int> GetTotalSalesCountAsync(DateTime? fromDate = null, DateTime? toDate = null);
        
        // For Admin Purchase Report - includes all related entities
        Task<IEnumerable<Purchase>> GetAllWithDetailsAsync(DateTime? fromDate = null, DateTime? toDate = null);
    }
}
