using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MedicalVending.Domain.Exceptions;

namespace MedicalVending.Infrastructure.Repositories
{
    public class MedicineRepository : BaseRepository, IMedicineRepository
    {
        public MedicineRepository(ApplicationDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<Medicine>> GetByIdsAsync(IEnumerable<int> ids)
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Medicines
                    .Where(m => ids.Contains(m.MedicineId))
                    .ToListAsync(),
                "Error retrieving medicines by IDs");
        }

        public async Task<IEnumerable<Medicine>> SearchAsync(
            string? name = null,
            int? categoryId = null,
            int pageNumber = 1,
            int pageSize = 20)
        {
            return await ExecuteSafelyAsync(async () =>
            {
                var query = _context.Medicines.AsQueryable();

                if (!string.IsNullOrEmpty(name))
                    query = query.Where(m => m.MedicineName.Contains(name));

                if (categoryId.HasValue)
                    query = query.Where(m => m.CategoryId == categoryId);

                return await query
                    .OrderBy(m => m.MedicineName)
                    .Skip((pageNumber - 1) * pageSize)
                    .Take(pageSize)
                    .AsNoTracking()
                    .ToListAsync();
            }, "Error searching medicines");
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Medicines.AnyAsync(m => m.MedicineId == id),
                $"Error checking medicine existence with ID {id}");
        }

        public async Task<int> GetCountInCategoryAsync(int categoryId)
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Medicines.CountAsync(m => m.CategoryId == categoryId),
                $"Error counting medicines in category ID {categoryId}");
        }

        public async Task<int> AddAsync(Medicine medicine)
        {
            return await ExecuteSafelyAsync(async () =>
            {
                await _context.Medicines.AddAsync(medicine);
                await _context.SaveChangesAsync();
                return medicine.MedicineId;
            }, "Error adding medicine");
        }

        public async Task UpdateAsync(Medicine medicine)
        {
            await ExecuteSafelyAsync(async () =>
            {
                // Check if the entity exists
                await EnsureEntityExistsAsync<Medicine>(medicine.MedicineId, ExistsAsync, "Medicine");
                
                _context.Medicines.Update(medicine);
                await _context.SaveChangesAsync();
            }, $"Error updating medicine with ID {medicine.MedicineId}");
        }

        public async Task DeleteAsync(int id)
        {
            await ExecuteSafelyAsync(async () =>
            {
                var medicine = await _context.Medicines.FindAsync(id);
                if (medicine != null)
                {
                    _context.Medicines.Remove(medicine);
                    await _context.SaveChangesAsync();
                }
                else
                {
                    throw new NotFoundException("Medicine", id);
                }
            }, $"Error deleting medicine with ID {id}");
        }

        public async Task<IEnumerable<Medicine>> GetExpiringSoonAsync(DateTime thresholdDate)
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Medicines
                    .Where(m => m.ExpirationDate <= thresholdDate)
                    .OrderBy(m => m.ExpirationDate)
                    .AsNoTracking()
                    .ToListAsync(),
                "Error retrieving medicines expiring soon");
        }

        public async Task<Medicine?> GetByIdAsync(int id)
        {
            return await ExecuteSafelyAsync(async () =>
            {
                var medicine = await _context.Medicines
                   .Include(m => m.Category)
                   .FirstOrDefaultAsync(m => m.MedicineId == id);
                
                if (medicine == null)
                {
                    throw new NotFoundException("Medicine", id);
                }
                
                return medicine;
            }, $"Error retrieving medicine with ID {id}");
        }

        public async Task<IEnumerable<Medicine>> GetMedicinesForMachineAsync(int machineId)
        {
            return await ExecuteSafelyAsync(async () =>
                await _context.Medicines
                    .Include(m => m.Category)
                    .Where(m => m.MachineMedicines.Any(mm => mm.MachineId == machineId))
                    .ToListAsync(),
                $"Error retrieving medicines for machine with ID {machineId}");
        }
    }
}
