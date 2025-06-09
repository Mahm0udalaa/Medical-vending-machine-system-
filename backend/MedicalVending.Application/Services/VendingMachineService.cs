using AutoMapper;
using MedicalVending.Application.DTOs.MachineMediciens;
using MedicalVending.Application.DTOs.VendingMachiens;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

namespace MedicalVending.Application.Services
{
    public class VendingMachineService : IVendingMachineService
    {
        private readonly IVendingMachineRepository _machineRepository;
        private readonly IMedicineRepository _medicineRepository;
        private readonly IMapper _mapper;

        public VendingMachineService(
            IVendingMachineRepository machineRepository,
            IMedicineRepository medicineRepository,
            IMapper mapper)
        {
            _machineRepository = machineRepository;
            _medicineRepository = medicineRepository;
            _mapper = mapper;
        }

        public async Task<MachineDto> GetAsync(int id)
        {
            var machine = await _machineRepository.GetByIdAsync(id)
                ?? throw new NotFoundException("Machine not found");
            return _mapper.Map<MachineDto>(machine);
        }

        public async Task<IEnumerable<MachineDto>> GetAllAsync()
        {
            var machines = await _machineRepository.GetAllAsync();
            return _mapper.Map<IEnumerable<MachineDto>>(machines);
        }

        public async Task<MachineDto> CreateAsync(CreateMachineDto dto)
        {
            var machine = _mapper.Map<VendingMachine>(dto);
            await _machineRepository.AddAsync(machine);
            return _mapper.Map<MachineDto>(machine);
        }

        public async Task DeleteAsync(int id)
        {
            if (!await _machineRepository.ExistsAsync(id))
                throw new NotFoundException("Machine not found");

            await _machineRepository.DeleteAsync(id);
        }

        public async Task<IEnumerable<MachineStockDto>> GetMachineStockAsync(int machineId)
        {
            var machine = await _machineRepository.GetWithStockAsync(machineId)
                ?? throw new NotFoundException("Machine not found");

            return machine.MachineMedicines.Select(mm => new MachineStockDto
            {
                MachineId = machine.MachineId,
                MachineLocation = machine.Location,
                MedicineId = mm.MedicineId,
                MedicineName = mm.Medicine!.MedicineName,
                MedicinePrice = mm.Medicine.MedicinePrice,
                Quantity = mm.Quantity,
                Slot = mm.Slot
            });
        }

        public async Task RestockMachineAsync(int machineId, List<UpdateStockDto> updates)
        {
            var machine = await _machineRepository.GetWithStockAsync(machineId)
                ?? throw new NotFoundException("Machine not found");

            // Validate all medicines exist
            var medicineIds = updates.Select(u => u.MedicineId).Distinct();
            var existingMedicines = await _medicineRepository.GetByIdsAsync(medicineIds);
            if (existingMedicines.Count() != medicineIds.Count())
                throw new NotFoundException("Some medicines not found");

            foreach (var update in updates)
            {
                var machineMedicine = machine.MachineMedicines
                    .FirstOrDefault(mm => mm.MedicineId == update.MedicineId)
                    ?? throw new InvalidOperationException($"Medicine {update.MedicineId} not in machine");

                machineMedicine.Quantity = update.Quantity;
                machineMedicine.LastRestocked = DateTime.UtcNow;
            }

            await _machineRepository.UpdateAsync(machine);
        }

        public async Task UpdateAsync(int id, UpdateMachineDto dto)
        {
            if (!await _machineRepository.ExistsAsync(id))
                throw new NotFoundException("Machine not found");

            var machine = await _machineRepository.GetByIdAsync(id)
                ?? throw new NotFoundException("Machine not found");

            _mapper.Map(dto, machine);

            await _machineRepository.UpdateAsync(machine);
        }

        public async Task<IEnumerable<MachineDto>> GetMachinesByAdminIdAsync(int adminId)
        {
            var machines = await _machineRepository.GetAllAsync();
            var adminMachines = machines.Where(m => m.AdminId == adminId);
            return _mapper.Map<IEnumerable<MachineDto>>(adminMachines);
        }
    }
}
