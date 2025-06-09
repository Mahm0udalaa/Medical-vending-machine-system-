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
            return Ok(admins);
        }

        /// <summary>
        /// Get an admin by ID.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<AdminDto>> GetAdmin(int id)
        {
            var admin = await _adminService.GetByIdAsync(id);
            if (admin == null)
                return NotFound("Admin not found.");
            return Ok(admin);
        }

        /// <summary>
        /// Create a new admin.
        /// </summary>
        [HttpPost]
        public async Task<ActionResult> CreateAdmin([FromBody] CreateAdminDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid admin data.");

            await _adminService.AddAsync(dto);
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

            await _adminService.UpdateAsync(id, dto);
            return NoContent();
        }

        /// <summary>
        /// Delete an admin by ID.
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteAdmin(int id)
        {
            await _adminService.DeleteAsync(id);
            return NoContent();
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
