using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Interfaces
{
    public interface ICartRepository
    {
        Task<List<Cart>> GetCartItemsByCustomerAsync(int customerId);
        Task RemoveCartItemsAsync(List<Cart> cartItems);
    }
} 