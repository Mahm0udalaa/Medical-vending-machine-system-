using MedicalVending.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface IMedicineRepository
    {
        // Read operations
        Task<Medicine?> GetByIdAsync(int id);
        Task<IEnumerable<Medicine>> GetByIdsAsync(IEnumerable<int> ids);
        Task<IEnumerable<Medicine>> SearchAsync(
            string? name = null,
            int? categoryId = null,
            int pageNumber = 1,
            int pageSize = 20);

        Task<bool> ExistsAsync(int id);
        Task<int> GetCountInCategoryAsync(int categoryId); // For category stats

        // Write operations
        Task<int> AddAsync(Medicine medicine);
        Task UpdateAsync(Medicine medicine);
        Task DeleteAsync(int id);

        // Domain-specific
        Task<IEnumerable<Medicine>> GetExpiringSoonAsync(DateTime thresholdDate);
        Task<IEnumerable<Medicine>> GetMedicinesForMachineAsync(int machineId);
    }

}
