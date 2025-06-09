using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public class CategoryRepository : ICategoryRepository
    {
        private readonly ApplicationDbContext _context;

        public CategoryRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Category>> GetAllAsync()
       => await _context.Categories
           .AsNoTracking()
           .ToListAsync();

        //public async Task<Category?> GetByIdAsync(int id)
        //{
        //    return await _context.Categories.FindAsync(id);
        //}
        public async Task<Category?> GetByIdAsync(int id)
        => await _context.Categories
            .Include(c => c.Medicines) // Eager load medicines
            .FirstOrDefaultAsync(c => c.CategoryId == id);

        public async Task AddAsync(Category category)
        {
            await _context.Categories.AddAsync(category);
            await _context.SaveChangesAsync();
        }

        //public async Task UpdateAsync(Category category)
        //{
        //    _context.Categories.Update(category);
        //    await _context.SaveChangesAsync();
        //}

        public async Task UpdateAsync(Category category)
        {
            _context.Entry(category).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        //public async Task DeleteAsync(int id)
        //{
        //    var category = await _context.Categories.FindAsync(id);
        //    if (category != null)
        //    {
        //        _context.Categories.Remove(category);
        //        await _context.SaveChangesAsync();
        //    }
        //}

        public async Task DeleteAsync(int id)
        {
            await _context.Categories
                .Where(c => c.CategoryId == id)
                .ExecuteDeleteAsync();
        }

        public async Task<bool> ExistsAsync(int id)
       => await _context.Categories
           .AnyAsync(c => c.CategoryId == id);
    }
}
