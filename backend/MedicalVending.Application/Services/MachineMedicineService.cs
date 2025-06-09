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
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

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
            // Validate input
            if (dto.Quantity <= 0)
            {
                throw new InvalidOperationException("Quantity must be greater than 0");
            }

            // Check if machine exists
            var machine = await _machineRepository.GetByIdAsync(dto.MachineId)
                ?? throw new NotFoundException($"Vending machine with ID {dto.MachineId} not found");

            // Check if medicine exists
            var medicine = await _medicineRepository.GetByIdAsync(dto.MedicineId)
                ?? throw new NotFoundException($"Medicine with ID {dto.MedicineId} not found");

            // Validate initial quantity
            if (dto.Quantity > 6)
            {
                throw new InvalidOperationException(JsonSerializer.Serialize(new
                {
                    message = "Initial quantity cannot exceed the maximum slot capacity of 6 units",
                    attemptedQuantity = dto.Quantity,
                    maxAllowed = 6
                }));
            }

            // Get all medicines in the machine
            var machineMedicines = await _repository.GetByMachineIdAsync(dto.MachineId);
            
            // Check if this medicine already exists in the machine (regardless of slot)
            var existingMedicine = machineMedicines.FirstOrDefault(mm => mm.MedicineId == dto.MedicineId);
            if (existingMedicine != null)
            {
                throw new InvalidOperationException(JsonSerializer.Serialize(new
                {
                    message = $"Medicine {medicine.MedicineName} is already in the machine in slot {existingMedicine.Slot}",
                    existingSlot = existingMedicine.Slot,
                    currentQuantity = existingMedicine.Quantity
                }));
            }

            // Check if slot exists in the machine
            var existingSlot = machineMedicines.FirstOrDefault(mm => mm.Slot == dto.Slot);

            if (existingSlot != null)
            {
                // If slot exists but has different medicine
                if (existingSlot.MedicineId != dto.MedicineId)
                {
                    // Get all available slots (empty slots)
                    var takenSlots = machineMedicines.Select(mm => mm.Slot).ToList();
                    var availableSlots = Enumerable.Range(1, 6)
                        .Select(slot => slot.ToString())
                        .Where(slot => !takenSlots.Contains(slot))
                        .ToList();

                    throw new InvalidOperationException(JsonSerializer.Serialize(new
                    {
                        message = $"Slot {dto.Slot} already contains a different medicine",
                        availableSlots = availableSlots,
                        currentSlotContents = new
                        {
                            slot = existingSlot.Slot,
                            medicineId = existingSlot.MedicineId,
                            quantity = existingSlot.Quantity
                        }
                    }));
                }

                // If slot exists with same medicine, check quantity limit
                if (existingSlot.Quantity + dto.Quantity > 6)
                {
                    throw new InvalidOperationException(JsonSerializer.Serialize(new
                    {
                        message = "Adding this quantity would exceed the maximum slot capacity of 6 units",
                        currentQuantity = existingSlot.Quantity,
                        attemptedQuantity = dto.Quantity,
                        availableSpace = 6 - existingSlot.Quantity
                    }));
                }

                // Update existing slot
                existingSlot.Quantity += dto.Quantity;
                existingSlot.LastRestocked = DateTime.UtcNow;
                await _repository.UpdateAsync(existingSlot);

                // Update medicine stock
                medicine.Stock -= dto.Quantity;
                await _medicineRepository.UpdateAsync(medicine);

                return new MachineStockDto
                {
                    MachineId = machine.MachineId,
                    MachineLocation = machine.Location,
                    MedicineId = medicine.MedicineId,
                    MedicineName = medicine.MedicineName,
                    MedicinePrice = medicine.MedicinePrice,
                    Quantity = existingSlot.Quantity,
                    CategoryId = medicine.CategoryId,
                    Description = medicine.Description,
                    ImagePath = medicine.ImagePath,
                    Slot = dto.Slot
                };
            }

            // Create new machine medicine entry only if slot doesn't exist
            var machineMedicine = new MachineMedicine
            {
                MachineId = dto.MachineId,
                MedicineId = dto.MedicineId,
                Quantity = dto.Quantity,
                Slot = dto.Slot,
                LastRestocked = DateTime.UtcNow
            };

            await _repository.AddAsync(machineMedicine);

            // Update medicine stock
            medicine.Stock -= dto.Quantity;
            await _medicineRepository.UpdateAsync(medicine);

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
