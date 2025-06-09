using MedicalVending.Application.DTOs.Medicines;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    public interface IMedicineService
    {
        Task<IEnumerable<MedicineDto>> GetAllAsync();
        Task<MedicineDto?> GetByIdAsync(int id);
        Task<int> AddAsync(CreateMedicineDto dto, string? imageUrl = null);
        Task UpdateAsync(int id, UpdateMedicineDto dto, string? imageUrl = null);
        Task DeleteAsync(int id);
        Task<IEnumerable<MedicineDto>> GetMedicinesByCategoryAsync(int categoryId);
        Task<IEnumerable<MedicineDto>> GetMedicinesForMachineAsync(int machineId);
        Task<IEnumerable<MedicineDto>> GetExpiringSoonAsync(int daysThreshold);
        Task<IEnumerable<MedicineSimpleDto>> GetSimplifiedListAsync();
    }
}
