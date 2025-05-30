using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public class MachineMedicineRepository : IMachineMedicineRepository
    {
        private readonly ApplicationDbContext _context;

        public MachineMedicineRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<MachineMedicine?> GetByIdAsync(int machineId, int medicineId)
            => await _context.MachineMedicines
                .Include(mm => mm.VendingMachine)
                .Include(mm => mm.Medicine)
                .FirstOrDefaultAsync(mm =>
                    mm.MachineId == machineId &&
                    mm.MedicineId == medicineId);

        public async Task<IEnumerable<MachineMedicine>> GetByMachineAsync(int machineId)
            => await _context.MachineMedicines
                .Where(mm => mm.MachineId == machineId)
                .Include(mm => mm.Medicine)
                .AsNoTracking()
                .ToListAsync();

        public async Task<IEnumerable<MachineMedicine>> GetLowStockItemsAsync(int threshold)
            => await _context.MachineMedicines
                .Where(mm => mm.Quantity <= threshold)
                .Include(mm => mm.VendingMachine)
                .Include(mm => mm.Medicine)
                .AsNoTracking()
                .ToListAsync();

        public async Task<bool> ExistsAsync(int machineId, int medicineId)
            => await _context.MachineMedicines
                .AnyAsync(mm =>
                    mm.MachineId == machineId &&
                    mm.MedicineId == medicineId);

        public async Task AddAsync(MachineMedicine machineMedicine)
        {
            await _context.MachineMedicines.AddAsync(machineMedicine);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(MachineMedicine machineMedicine)
        {
            _context.MachineMedicines.Update(machineMedicine);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int machineId, int medicineId)
        {
            await _context.MachineMedicines
                .Where(mm =>
                    mm.MachineId == machineId &&
                    mm.MedicineId == medicineId)
                .ExecuteDeleteAsync();
        }

        public async Task<IEnumerable<MachineMedicine>> GetByMachineIdAsync(int machineId)
        {
            return await _context.MachineMedicines
                .Include(mm => mm.Medicine)
                .Include(mm => mm.VendingMachine)
                .Where(mm => mm.MachineId == machineId)
                .ToListAsync();
        }

        public async Task<IEnumerable<MachineMedicine>> GetByMedicineIdAsync(int medicineId)
        {
            return await _context.MachineMedicines
                .Where(mm => mm.MedicineId == medicineId)
                .Include(mm => mm.VendingMachine)
                .ToListAsync();
        }
    }
}
