using AutoMapper;
using MedicalVending.Application.DTOs.FavoritesMedicines;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Services
{
    public class FavoritesMedicineService : IFavoritesMedicineService
    {
        private readonly IFavoritesMedicineRepository _favoritesRepo;
        private readonly IMedicineRepository _medicineRepo;
        private readonly ICustomerRepository _customerRepo;
        private readonly IMapper _mapper;

        public FavoritesMedicineService(
            IFavoritesMedicineRepository favoritesRepo,
            IMedicineRepository medicineRepo,
            ICustomerRepository customerRepo,
            IMapper mapper)
        {
            _favoritesRepo = favoritesRepo;
            _medicineRepo = medicineRepo;
            _customerRepo = customerRepo;
            _mapper = mapper;
        }

        public async Task<IEnumerable<FavoriteDto>> GetCustomerFavoritesAsync(int customerId)
        {
            if (!await _customerRepo.ExistsAsync(customerId))
                throw new NotFoundException(nameof(Customer), customerId);

            var favorites = await _favoritesRepo.GetFavoritesByCustomerAsync(customerId);

            return favorites.Any()
                ? _mapper.Map<IEnumerable<FavoriteDto>>(favorites)
                : Enumerable.Empty<FavoriteDto>();
        }

        public async Task AddFavoriteAsync(AddFavoriteDto dto)
        {
            // Check customer existence first
            if (!await _customerRepo.ExistsAsync(dto.CustomerId))
                throw new NotFoundException(nameof(Customer), dto.CustomerId);

            // Then check medicine existence
            if (!await _medicineRepo.ExistsAsync(dto.MedicineId))
                throw new NotFoundException(nameof(Medicine), dto.MedicineId);

            // check if favorite already exists
            if (await _favoritesRepo.ExistsAsync(dto.CustomerId, dto.MedicineId))
                throw new ConflictException("Medicine already in favorites");

            // Add the favorite
            await _favoritesRepo.AddAsync(dto.CustomerId, dto.MedicineId);
        }

        public async Task RemoveFavoriteAsync(int customerId, int medicineId)
        {
            // Check if favorite exists 
            if (!await _favoritesRepo.ExistsAsync(customerId, medicineId))
                throw new NotFoundException("Favorite entry", new { customerId, medicineId });

            await _favoritesRepo.RemoveAsync(customerId, medicineId);
        }
    }
}
