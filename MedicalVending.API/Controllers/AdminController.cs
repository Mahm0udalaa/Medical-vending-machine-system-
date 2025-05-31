using MedicalVending.Application.DTOs.Admins;
using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Policy = "AdminOnly")]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _adminService;
        private readonly IPurchaseService _purchaseService;

        public AdminController(IAdminService adminService, IPurchaseService purchaseService)
        {
            _adminService = adminService;
            _purchaseService = purchaseService;
        }

        /// <summary>
        /// Get all admins.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AdminDto>>> GetAdmins()
        {
            var admins = await _adminService.GetAllAsync();
            return Ok(admins); // 200 OK with the list of AdminDto
        }

        /// <summary>
        /// Get an admin by ID.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<AdminDto>> GetAdmin(int id)
        {
            // The service will throw NotFoundException if admin not found,
            // which will be caught by the global exception middleware
            var admin = await _adminService.GetByIdAsync(id);
            if (admin == null)
                return NotFound("Admin not found.");
            return Ok(admin); // 200 OK with a single AdminDto
        }

        /// <summary>
        /// Create a new admin.
        /// </summary>
        [HttpPost]
        //[AllowAnonymous]
        public async Task<ActionResult> CreateAdmin([FromBody] CreateAdminDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid admin data.");

            await _adminService.AddAsync(dto);
            // Optionally, you can return the newly created resource if your service returns it
            // For example:
            // var createdAdmin = await _adminService.AddAsync(dto);
            // return CreatedAtAction(nameof(GetAdmin), new { id = createdAdmin.AdminId }, createdAdmin);

            return Ok("Admin created successfully.");
        }

        /// <summary>
        /// Update an existing admin.
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult> UpdateAdmin(int id, [FromBody] UpdateAdminDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid admin data.");

            // The service will throw an exception or handle 'not found' internally
            await _adminService.UpdateAsync(id, dto);
            return NoContent(); // 204 No Content
        }

        /// <summary>
        /// Delete an admin by ID.
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteAdmin(int id)
        {
            // The service will handle 'not found' case internally
            await _adminService.DeleteAsync(id);
            return NoContent(); // 204 No Content
        }

        /// <summary>
        /// Get all purchases for a specific vending machine.
        /// </summary>
        [HttpGet("machines/{machineId}/purchases")]
        public async Task<ActionResult<IEnumerable<PurchaseDto>>> GetMachinePurchases(int machineId)
        {
            var purchases = await _purchaseService.GetMachinePurchasesAsync(machineId);
            return Ok(purchases);
        }
    }
}
