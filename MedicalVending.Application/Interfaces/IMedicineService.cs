using MedicalVending.Application.DTOs.Medicines;
using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    public interface IMedicineService
    {
        Task<IEnumerable<MedicineDto>> GetAllAsync();
        Task<MedicineDto?> GetByIdAsync(int id);
        Task<int> AddAsync(CreateMedicineDto dto);
        Task UpdateAsync(int id, UpdateMedicineDto dto);
        Task DeleteAsync(int id);
        Task<IEnumerable<MedicineDto>> GetMedicinesByCategoryAsync(int categoryId);
        Task<IEnumerable<MedicineDto>> GetExpiringSoonAsync(int daysThreshold);
        Task<IEnumerable<MedicineSimpleDto>> GetSimplifiedListAsync();
    }
}
