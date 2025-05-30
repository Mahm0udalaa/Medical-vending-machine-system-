using MedicalVending.Application.DTOs.Customers;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
   

    public interface ICustomerService :
    ICrudService<CustomerDto, RegisterCustomerDto, UpdateCustomerDto, int>
    {
        // Auth-specific methods
        //Task<LoginResponseDto> LoginAsync(string email, string password);
        //Task ChangePasswordAsync(int customerId, string newPassword);
        Task SetPasswordAsync(int customerId, string password);
        Task<int> GetCustomerCountAsync();
        Task<CustomerDto?> GetCustomerByEmailAsync(string email);
    }
    public interface ICustomerAuthService
    {
    }
}
