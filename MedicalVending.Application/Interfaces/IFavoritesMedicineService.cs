using MedicalVending.Application.DTOs.FavoritesMedicines;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
   

    public interface IFavoritesMedicineService
    {
        Task<IEnumerable<FavoriteDto>> GetCustomerFavoritesAsync(int customerId);
        Task AddFavoriteAsync(AddFavoriteDto dto);
        Task RemoveFavoriteAsync(int customerId, int medicineId);
        // No GetAll/GetById (favorites are customer-specific)
    }
}
