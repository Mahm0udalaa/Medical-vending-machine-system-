using MedicalVending.Application.DTOs.MachineMediciens;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
 
    public interface IMachineMedicineService
    {
        Task<MachineStockDto> GetStockAsync(int machineId, int medicineId);
        Task UpdateStockAsync(UpdateStockDto dto);
        Task<IEnumerable<MachineStockDto>> GetLowStockItemsAsync(int threshold);
        Task<IEnumerable<MachineStockDto>> GetMedicinesInMachineAsync(int machineId);
        Task<MachineStockDto> AddMedicineToMachineAsync(AddMedicineToMachineDto dto);
        Task DeleteMedicineFromMachineAsync(int machineId, int medicineId);
        Task<IEnumerable<MachineWithLocationDto>> GetMachinesByMedicineIdAsync(int medicineId);
        // No CRUD (stock is managed via vending machine/medicine relationships)
    }
}
