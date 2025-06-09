using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Repositories
{
    public class CartRepository : ICartRepository
    {
        private readonly ApplicationDbContext _context;
        public CartRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Cart>> GetCartItemsByCustomerAsync(int customerId)
        {
            return await _context.Carts
                .Where(c => c.CustomerId == customerId)
                .ToListAsync();
        }

        public async Task RemoveCartItemsAsync(List<Cart> cartItems)
        {
            _context.Carts.RemoveRange(cartItems);
            await _context.SaveChangesAsync();
        }
    }
} 