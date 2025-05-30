using AutoMapper;
using MedicalVending.Application.DTOs.Medicines;
using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Services
{
    public class MedicineService : IMedicineService
    {
        private readonly IMedicineRepository _medicineRepository;
        private readonly IMapper _mapper;
        private readonly IBlobStorageService _blobStorageService;

        public MedicineService(
            IMedicineRepository medicineRepository, 
            IMapper mapper,
            IBlobStorageService blobStorageService)
        {
            _medicineRepository = medicineRepository;
            _mapper = mapper;
            _blobStorageService = blobStorageService;
        }

        public async Task<IEnumerable<MedicineDto>> GetAllAsync()
        {
            var medicines = await _medicineRepository.SearchAsync();
            return _mapper.Map<IEnumerable<MedicineDto>>(medicines);
        }

        public async Task<MedicineDto?> GetByIdAsync(int id)
        {
            var medicine = await _medicineRepository.GetByIdAsync(id);
            return medicine == null ? null : _mapper.Map<MedicineDto>(medicine);
        }

        public async Task<int> AddAsync(CreateMedicineDto dto)
        {
            var medicine = _mapper.Map<Medicine>(dto);

            // Assign image string directly if provided
            if (!string.IsNullOrEmpty(dto.image))
            {
                medicine.ImagePath = dto.image;
            }

            try
            {
                await _medicineRepository.AddAsync(medicine);
                return medicine.MedicineId;
            }
            catch (Exception ex)
            {
                // Log or rethrow with inner exception details
                var errorMessage = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                throw new Exception($"Error adding medicine: {errorMessage}", ex);
            }
        }

        public async Task UpdateAsync(int id, UpdateMedicineDto dto)
        {
            var medicine = await _medicineRepository.GetByIdAsync(id);
            if (medicine == null)
                throw new NotFoundException(nameof(Medicine), id);

            _mapper.Map(dto, medicine);

            // Assign image string directly if provided
            if (!string.IsNullOrEmpty(dto.image))
            {
                medicine.ImagePath = dto.image;
            }

            await _medicineRepository.UpdateAsync(medicine);
        }

        public async Task DeleteAsync(int id)
        {
            var medicine = await _medicineRepository.GetByIdAsync(id);
            if (medicine == null)
                throw new NotFoundException(nameof(Medicine), id);

            // Delete image from blob storage if exists
            if (!string.IsNullOrEmpty(medicine.ImagePath))
            {
                var oldFileName = System.IO.Path.GetFileName(new Uri(medicine.ImagePath).AbsolutePath);
                await _blobStorageService.DeletePhotoAsync("medicine-images", oldFileName);
            }

            await _medicineRepository.DeleteAsync(id);
        }

        public async Task<IEnumerable<MedicineDto>> GetMedicinesByCategoryAsync(int categoryId)
        {
            var medicines = await _medicineRepository.SearchAsync(categoryId: categoryId);
            return _mapper.Map<IEnumerable<MedicineDto>>(medicines);
        }

        public async Task<IEnumerable<MedicineDto>> GetExpiringSoonAsync(int daysThreshold)
        {
            var thresholdDate = DateTime.UtcNow.AddDays(daysThreshold);
            var medicines = await _medicineRepository.GetExpiringSoonAsync(thresholdDate);
            return _mapper.Map<IEnumerable<MedicineDto>>(medicines);
        }

        public async Task<IEnumerable<MedicineSimpleDto>> GetSimplifiedListAsync()
        {
            var medicines = await _medicineRepository.SearchAsync();
            return _mapper.Map<IEnumerable<MedicineSimpleDto>>(medicines);
        }
    }
}
