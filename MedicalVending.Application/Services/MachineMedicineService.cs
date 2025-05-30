using AutoMapper;
using MedicalVending.Application.DTOs.MachineMediciens;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

namespace MedicalVending.Application.Services
{
    public class MachineMedicineService : IMachineMedicineService
    {
        private readonly IMachineMedicineRepository _repository;
        private readonly IMapper _mapper;
        private readonly IVendingMachineRepository _machineRepository;
        private readonly IMedicineRepository _medicineRepository;

        public MachineMedicineService(
            IMachineMedicineRepository repository,
            IMapper mapper,
            IVendingMachineRepository machineRepository,
            IMedicineRepository medicineRepository)
        {
            _repository = repository;
            _mapper = mapper;
            _machineRepository = machineRepository;
            _medicineRepository = medicineRepository;
        }

        public async Task<MachineStockDto> GetStockAsync(int machineId, int medicineId)
        {
            var stock = await _repository.GetByIdAsync(machineId, medicineId);
            if (stock == null)
                throw new NotFoundException("Stock entry", new { machineId, medicineId });

            return _mapper.Map<MachineStockDto>(stock);
        }

        public async Task UpdateStockAsync(UpdateStockDto dto)
        {
            var stock = await _repository.GetByIdAsync(dto.MachineId, dto.MedicineId);
            if (stock == null)
                throw new NotFoundException("Stock entry", new { dto.MachineId, dto.MedicineId });

            stock.Quantity = dto.Quantity;
            await _repository.UpdateAsync(stock);
        }

        public async Task<IEnumerable<MachineStockDto>> GetLowStockItemsAsync(int threshold)
        {
            var lowStockItems = await _repository.GetLowStockItemsAsync(threshold);
            return _mapper.Map<IEnumerable<MachineStockDto>>(lowStockItems);
        }

        public async Task<IEnumerable<MachineStockDto>> GetMedicinesInMachineAsync(int machineId)
        {
            var machineMedicines = await _repository.GetByMachineIdAsync(machineId);
            return machineMedicines.Select(mm => new MachineStockDto
            {
                MachineId = mm.MachineId,
                MachineLocation = mm.VendingMachine.Location,
                MedicineId = mm.MedicineId,
                MedicineName = mm.Medicine.MedicineName,
                MedicinePrice = mm.Medicine.MedicinePrice,
                Quantity = mm.Quantity,
                CategoryId = mm.Medicine.CategoryId,
                Description = mm.Medicine.Description,
                ImagePath = mm.Medicine.ImagePath,
                Slot = mm.Slot
            });
        }

        public async Task<MachineStockDto> AddMedicineToMachineAsync(AddMedicineToMachineDto dto)
        {
            // Check if machine exists
            var machine = await _machineRepository.GetByIdAsync(dto.MachineId)
                ?? throw new NotFoundException($"Vending machine with ID {dto.MachineId} not found");

            // Check if medicine exists
            var medicine = await _medicineRepository.GetByIdAsync(dto.MedicineId)
                ?? throw new NotFoundException($"Medicine with ID {dto.MedicineId} not found");

            // Check if this medicine is already in the machine
            var exists = await _repository.ExistsAsync(dto.MachineId, dto.MedicineId);
            if (exists)
            {
                throw new InvalidOperationException($"Medicine {dto.MedicineId} is already in machine {dto.MachineId}");
            }

            // Create new machine medicine entry - don't include full entity objects
            var machineMedicine = new MachineMedicine
            {
                MachineId = dto.MachineId,
                MedicineId = dto.MedicineId,
                Quantity = dto.Quantity,
                Slot = dto.Slot,
                LastRestocked = DateTime.UtcNow
            };

            await _repository.AddAsync(machineMedicine);

            return new MachineStockDto
            {
                MachineId = machine.MachineId,
                MachineLocation = machine.Location,
                MedicineId = medicine.MedicineId,
                MedicineName = medicine.MedicineName,
                MedicinePrice = medicine.MedicinePrice,
                Quantity = dto.Quantity,
                CategoryId = medicine.CategoryId,
                Description = medicine.Description,
                ImagePath = medicine.ImagePath,
                Slot = dto.Slot
            };
        }

        public async Task DeleteMedicineFromMachineAsync(int machineId, int medicineId)
        {
            await _repository.DeleteAsync(machineId, medicineId);
        }

        public async Task<IEnumerable<MachineWithLocationDto>> GetMachinesByMedicineIdAsync(int medicineId)
        {
            var machineMedicines = await _repository.GetByMedicineIdAsync(medicineId);
            return machineMedicines
                .Where(mm => mm.VendingMachine != null)
                .Select(mm => new MachineWithLocationDto
                {
                    MachineId = mm.MachineId,
                    Location = mm.VendingMachine!.Location
                });
        }
    }
}
