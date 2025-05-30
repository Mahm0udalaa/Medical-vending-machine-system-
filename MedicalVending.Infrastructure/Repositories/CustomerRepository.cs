using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    /// <summary>
    /// Handles database operations for the Customer entity.
    /// </summary>
    public class CustomerRepository : ICustomerRepository
    {
        private readonly ApplicationDbContext _context;

        public CustomerRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Customer?> GetByIdAsync(int id)
            => await _context.Customers.FindAsync(id);

        public async Task<IEnumerable<Customer>> GetPagedAsync(int pageNumber, int pageSize)
            => await _context.Customers
                .OrderBy(c => c.CustomerId)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync();

        public async Task<bool> ExistsAsync(int id)
            => await _context.Customers.AnyAsync(c => c.CustomerId == id);

        public async Task<bool> ExistsByEmailAsync(string email)
            => await _context.Customers.AnyAsync(c => c.CustomerEmail == email);

        public async Task AddAsync(Customer customer)
        {
            await _context.Customers.AddAsync(customer);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Customer customer)
        {
            _context.Customers.Update(customer);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            await _context.Customers
                .Where(c => c.CustomerId == id)
                .ExecuteDeleteAsync();
        }

        public async Task<int> GetTotalCountAsync()
            => await _context.Customers.CountAsync();

        public async Task<Customer?> GetByEmailAsync(string email)
            => await _context.Customers
                .FirstOrDefaultAsync(c => c.CustomerEmail == email);
    }
}
