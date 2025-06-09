using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface IFavoritesMedicineRepository
    {
        // Read operations
        Task<FavoritesMedicine?> GetByIdAsync(int customerId, int medicineId);
        Task<IEnumerable<FavoritesMedicine>> GetFavoritesByCustomerAsync(int customerId);

        // Write operations
        Task AddAsync(int customerId, int medicineId);
        Task RemoveAsync(int customerId, int medicineId);

        // Validation
        Task<bool> ExistsAsync(int customerId, int medicineId);

        // Optional performance optimization
        Task<int> CountCustomerFavoritesAsync(int customerId);
    }
}
