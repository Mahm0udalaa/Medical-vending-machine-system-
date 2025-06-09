using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalVending.Infrastructure.DataBase;
using MedicalVending.Domain.Entities;
using MedicalVending.Application.DTOs.Cart;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CartController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CartController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Cart/{customerId}
        [HttpGet("{customerId}")]
        public async Task<ActionResult<IEnumerable<CartDto>>> GetCustomerCart(int customerId)
        {
            var cartItems = await _context.Carts
                .Include(c => c.Medicine)
                .Include(c => c.Machine)
                .Join(_context.MachineMedicines,
                      cart => new { cart.MachineId, cart.MedicineId },
                      mm => new { mm.MachineId, mm.MedicineId },
                      (cart, mm) => new { cart, mm })
                .Where(x => x.cart.CustomerId == customerId)
                .Select(x => new CartDto
                {
                    Id = x.cart.Id,
                    MachineId = x.cart.MachineId,
                    MachineLocation = x.cart.Machine.Location,
                    MedicineId = x.cart.MedicineId,
                    Quantity = x.cart.Quantity,
                    MedicineName = x.cart.Medicine.MedicineName,
                    Price = x.cart.Medicine.MedicinePrice,
                    ImagePath = x.cart.Medicine.ImagePath,
                    Slot = x.mm.Slot
                })
                .ToListAsync();

            if (cartItems == null || cartItems.Count == 0)
                return NotFound("No items found for this customer.");

            return Ok(cartItems);
        }

        // DELETE: api/Cart/customer/{customerId}
        [HttpDelete("customer/{customerId}")]
        public async Task<IActionResult> DeleteAllCartItems(int customerId)
        {
            var customer = await _context.Customers.FindAsync(customerId);
            if (customer == null)
                return NotFound("Customer not found.");

            var cartItems = await _context.Carts.Where(c => c.CustomerId == customerId).ToListAsync();
            if (!cartItems.Any())
                return NotFound("No cart items found for this customer.");

            _context.Carts.RemoveRange(cartItems);
            await _context.SaveChangesAsync();
            return Ok(new { status = "Success", message = "All cart items deleted successfully." });
        }

        // POST: api/Cart
        [HttpPost]
        public async Task<IActionResult> AddToCart([FromBody] AddCartItemDto dto)
        {
            if (dto == null)
                return BadRequest(new { status = "Error", message = "Invalid request body." });

            // Check if customer exists
            var customer = await _context.Customers.FindAsync(dto.CustomerId);
            if (customer == null)
                return NotFound(new { status = "Error", message = "Customer not found." });

            // Check if medicine exists in the specified machine
            var medicineExists = await _context.MachineMedicines
                .AnyAsync(mm => mm.MachineId == dto.MachineId && mm.MedicineId == dto.MedicineId);
            if (!medicineExists)
                return NotFound(new { status = "Error", message = "Medicine not found in the specified machine." });

            // Check if item already exists in cart
            var exists = await _context.Carts.AnyAsync(c => c.CustomerId == dto.CustomerId && c.MedicineId == dto.MedicineId);
            if (exists)
                return BadRequest(new { status = "Error", message = "This medicine is already in the cart for this customer." });

            // Check machine consistency
            var existingCartItems = await _context.Carts
                .Where(c => c.CustomerId == dto.CustomerId)
                .Select(c => c.MachineId)
                .Distinct()
                .ToListAsync();

            if (existingCartItems.Any() && !existingCartItems.Contains(dto.MachineId))
            {
                return BadRequest(new { status = "Error", message = "Cannot add items from different machines to the same cart." });
            }

            var cart = new Cart
            {
                CustomerId = dto.CustomerId,
                MachineId = dto.MachineId,
                MedicineId = dto.MedicineId,
                Quantity = dto.Quantity
            };

            _context.Carts.Add(cart);
            await _context.SaveChangesAsync();

            return Ok(new { status = "Success" });
        }

        // PUT: api/Cart/{customerId}/{medicineId}
        [HttpPut("{customerId}/{medicineId}")]
        public async Task<IActionResult> UpdateCartItem(int customerId, int medicineId, [FromBody] UpdateCartQuantityDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid request body.");

            var cartItem = await _context.Carts.FirstOrDefaultAsync(c => c.CustomerId == customerId && c.MedicineId == medicineId);
            if (cartItem == null)
                return NotFound();

            cartItem.Quantity = dto.Quantity;
            await _context.SaveChangesAsync();
            return Ok(cartItem);
        }

        // DELETE: api/Cart
        [HttpDelete]
        public async Task<IActionResult> DeleteCartItem([FromQuery] int customerId, [FromQuery] int medicineId)
        {
            var cartItem = await _context.Carts.FirstOrDefaultAsync(c => c.CustomerId == customerId && c.MedicineId == medicineId);
            if (cartItem == null)
                return NotFound();

            _context.Carts.Remove(cartItem);
            await _context.SaveChangesAsync();
            return Ok();
        }

        private bool CartItemExists(int id)
        {
            return _context.Carts.Any(e => e.Id == id);
        }
    }
} 