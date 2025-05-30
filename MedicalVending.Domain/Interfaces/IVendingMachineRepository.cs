using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface IVendingMachineRepository
    {
        Task<VendingMachine?> GetByIdAsync(int id);
        Task<IEnumerable<VendingMachine>> GetAllAsync();
        Task AddAsync(VendingMachine machine);
        Task UpdateAsync(VendingMachine machine);
        Task DeleteAsync(int id);
        Task<bool> ExistsAsync(int id);

        // Domain-specific
        Task<VendingMachine?> GetWithStockAsync(int machineId);
    }
}
