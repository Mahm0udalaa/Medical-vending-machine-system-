using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface IMachineMedicineRepository
    {
        Task<MachineMedicine?> GetByIdAsync(int machineId, int medicineId);
        Task<IEnumerable<MachineMedicine>> GetByMachineAsync(int machineId);
        Task<IEnumerable<MachineMedicine>> GetLowStockItemsAsync(int threshold);
        Task<bool> ExistsAsync(int machineId, int medicineId);
        Task AddAsync(MachineMedicine machineMedicine);
        Task UpdateAsync(MachineMedicine machineMedicine);
        Task DeleteAsync(int machineId, int medicineId);
        Task<IEnumerable<MachineMedicine>> GetByMachineIdAsync(int machineId);
        Task<IEnumerable<MachineMedicine>> GetByMedicineIdAsync(int medicineId);
    }
}
