using MedicalVending.Application.DTOs.Customers;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //#if DEBUG
    //[AllowAnonymous] // This will override any Authorize attributes during development
    //#endif
    public class CustomerController : ControllerBase
    {
        private readonly ICustomerService _customerService;
        private readonly IPurchaseService _purchaseService;

        // Inject ICustomerService and IPurchaseService via constructor
        public CustomerController(ICustomerService customerService, IPurchaseService purchaseService)
        {
            _customerService = customerService;
            _purchaseService = purchaseService;
        }

        /// <summary>
        /// Retrieves all customers.
        /// </summary>
        [HttpGet]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult<IEnumerable<CustomerDto>>> GetCustomers()
        {
            var customers = await _customerService.GetAllAsync();
            return Ok(customers); // Returns 200 OK with list of CustomerDto
        }

        /// <summary>
        /// Retrieves a specific customer by ID.
        /// </summary>
        [HttpGet("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult<CustomerDto>> GetCustomer(int id)
        {
            var customer = await _customerService.GetByIdAsync(id);
            if (customer == null)
                return NotFound("Customer not found.");
            return Ok(customer); // Returns 200 OK with CustomerDto
        }

        /// <summary>
        /// Creates a new customer.
        /// </summary>
        [HttpPost]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> CreateCustomer([FromBody] RegisterCustomerDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid customer data.");

            await _customerService.AddAsync(dto);
            return StatusCode(201, "Customer created successfully."); // Returns 201 Created
        }

        /// <summary>
        /// Updates an existing customer.
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Policy = "CustomerOnly")]
        public async Task<IActionResult> UpdateCustomer(int id, [FromBody] UpdateCustomerDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _customerService.UpdateAsync(id, dto);
                return Ok(new { message = "Customer updated successfully" });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (BadRequestException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (ConflictException ex)
            {
                return Conflict(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while updating the customer", details = ex.Message });
            }
        }

        /// <summary>
        /// Deletes a customer by ID.
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult> DeleteCustomer(int id)
        {
            await _customerService.DeleteAsync(id);
            return NoContent(); // Returns 204 No Content on success
        }

        /// <summary>
        /// Manually sets password for a customer (Admin only)
        /// </summary>
        [HttpPost("{id}/set-password")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> SetCustomerPassword(int id, [FromBody] PasswordRequest request)
        {
            if (string.IsNullOrEmpty(request?.Password))
                return BadRequest("Password is required.");
                
            await _customerService.SetPasswordAsync(id, request.Password);
            return NoContent();
        }

        // Customer-specific endpoints
        [HttpGet("profile")]
        [Authorize(Policy = "CustomerOnly")]
        public async Task<ActionResult<CustomerDto>> GetCustomerProfile()
        {
            var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdString) || !int.TryParse(userIdString, out var customerId))
            {
                return Unauthorized(new { message = "Unable to determine user identity" });
            }
            
            var customer = await _customerService.GetByIdAsync(customerId);
            return Ok(customer);
        }

        [HttpPut("profile")]
        [Authorize(Policy = "CustomerOnly")]
        public async Task<IActionResult> UpdateCustomerProfile([FromBody] UpdateCustomerDto dto)
        {
            var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdString) || !int.TryParse(userIdString, out var customerId))
            {
                return Unauthorized(new { message = "Unable to determine user identity" });
            }
            
            await _customerService.UpdateAsync(customerId, dto);
            return NoContent();
        }

        [HttpGet("{customerId}/history")]
        [Authorize(Policy = "AllUsers")]
        public async Task<IActionResult> GetPurchaseHistory(int customerId)
        {
            var purchases = await _purchaseService.GetCustomerPurchasesAsync(customerId);
            return Ok(purchases);
        }
    }
    
    // Simple class to receive password in request body
    public class PasswordRequest
    {
        public string? Password { get; set; }
    }
}
