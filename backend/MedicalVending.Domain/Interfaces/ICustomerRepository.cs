using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface ICustomerRepository
    {
        // Read operations
        Task<Customer?> GetByIdAsync(int id);
        Task<IEnumerable<Customer>> GetPagedAsync(int pageNumber, int pageSize); // Better than GetAll
        Task<bool> ExistsAsync(int id);
        Task<bool> ExistsByEmailAsync(string email); // Added for auth/validation

        // Write operations
        Task AddAsync(Customer customer);
        Task UpdateAsync(Customer customer);
        Task DeleteAsync(int id);

        // Optional business-specific methods
        Task<int> GetTotalCountAsync();
        Task<Customer?> GetByEmailAsync(string email); // For authentication
    }
}
