using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public class VendingMachineRepository : IVendingMachineRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<VendingMachineRepository> _logger;

        public VendingMachineRepository(
            ApplicationDbContext context,
            ILogger<VendingMachineRepository> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<VendingMachine>> GetAllAsync()
        {
            try
            {
                return await _context.VendingMachines
                    .AsNoTracking()
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving all vending machines");
                throw;
            }
        }

        public async Task<VendingMachine?> GetByIdAsync(int id)
        {
            return await _context.VendingMachines
                .FirstOrDefaultAsync(vm => vm.MachineId == id);
        }

        public async Task AddAsync(VendingMachine vendingMachine)
        {
            await _context.VendingMachines.AddAsync(vendingMachine);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(VendingMachine vendingMachine)
        {
            try
            {
                var existing = await _context.VendingMachines
                    .FirstOrDefaultAsync(vm => vm.MachineId == vendingMachine.MachineId);

                if (existing == null)
                    throw new NotFoundException("Vending machine not found");

                // Manually assign properties to avoid EF creating a new entity
                existing.Location = vendingMachine.Location ?? existing.Location;
                existing.QR = vendingMachine.QR ?? existing.QR;
                existing.Capacity = vendingMachine.Capacity != 0 ? vendingMachine.Capacity : existing.Capacity;
                existing.AdminId = vendingMachine.AdminId != 0 ? vendingMachine.AdminId : existing.AdminId;
                existing.Latitude = vendingMachine.Latitude != 0 ? vendingMachine.Latitude : existing.Latitude;
                existing.Longitude = vendingMachine.Longitude != 0 ? vendingMachine.Longitude : existing.Longitude;
                existing.ImagePath = vendingMachine.ImagePath ?? existing.ImagePath;
                // Add any other fields as needed

                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException ex)
            {
                _logger.LogError(ex, "Concurrency error updating vending machine {Id}", vendingMachine.MachineId);
                throw;
            }
        }

        public async Task DeleteAsync(int id)
        {
            var machine = await _context.VendingMachines.FindAsync(id);
            if (machine == null) return;

            _context.VendingMachines.Remove(machine);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await _context.VendingMachines
                .AnyAsync(vm => vm.MachineId == id);
        }

        public async Task<VendingMachine?> GetWithStockAsync(int machineId)
        {
            return await _context.VendingMachines
                .Include(vm => vm.MachineMedicines)
                    .ThenInclude(mm => mm.Medicine)
                .AsSplitQuery() // Better performance for nested includes
                .FirstOrDefaultAsync(vm => vm.MachineId == machineId);
        }
    }
}
