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
using Microsoft.EntityFrameworkCore;

namespace MedicalVending.Application.Services
{
    public class MedicineService : IMedicineService
    {
        private readonly IMedicineRepository _medicineRepository;
        private readonly IMapper _mapper;
        private readonly IBlobStorageService _blobStorageService;
        private readonly IVendingMachineRepository _machineRepository;

        public MedicineService(
            IMedicineRepository medicineRepository,
            IMapper mapper,
            IBlobStorageService blobStorageService,
            IVendingMachineRepository machineRepository)
        {
            _medicineRepository = medicineRepository;
            _mapper = mapper;
            _blobStorageService = blobStorageService;
            _machineRepository = machineRepository;
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

        public async Task<int> AddAsync(CreateMedicineDto dto, string? imageUrl = null)
        {
            var medicine = _mapper.Map<Medicine>(dto);

            if (!string.IsNullOrEmpty(imageUrl))
            {
                medicine.ImagePath = imageUrl;
            }

            try
            {
                await _medicineRepository.AddAsync(medicine);
                return medicine.MedicineId;
            }
            catch (Exception ex)
            {
                var errorMessage = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                throw new Exception($"Error adding medicine: {errorMessage}", ex);
            }
        }

        public async Task UpdateAsync(int id, UpdateMedicineDto dto, string? imageUrl = null)
        {
            var medicine = await _medicineRepository.GetByIdAsync(id);
            if (medicine == null)
                throw new NotFoundException(nameof(Medicine), id);

            if (dto.MedicineName != null)
                medicine.MedicineName = dto.MedicineName;
            if (dto.MedicinePrice.HasValue)
                medicine.MedicinePrice = dto.MedicinePrice.Value;
            if (dto.Stock.HasValue)
                medicine.Stock = dto.Stock.Value;
            if (dto.ExpirationDate.HasValue)
                medicine.ExpirationDate = dto.ExpirationDate.Value;
            if (dto.Description != null)
                medicine.Description = dto.Description;
            if (dto.CategoryId.HasValue)
                medicine.CategoryId = dto.CategoryId.Value;
            if (!string.IsNullOrEmpty(imageUrl))
                medicine.ImagePath = imageUrl;

            await _medicineRepository.UpdateAsync(medicine);
        }

        public async Task DeleteAsync(int id)
        {
            var medicine = await _medicineRepository.GetByIdAsync(id);
            if (medicine == null)
                throw new NotFoundException(nameof(Medicine), id);

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

        public async Task<IEnumerable<MedicineDto>> GetMedicinesForMachineAsync(int machineId)
        {
            var machine = await _machineRepository.GetByIdAsync(machineId);
            if (machine == null)
                throw new NotFoundException(nameof(VendingMachine), machineId);

            var medicines = await _medicineRepository.GetMedicinesForMachineAsync(machineId);
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
