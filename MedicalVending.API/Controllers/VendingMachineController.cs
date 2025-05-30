using MedicalVending.Application.DTOs.VendingMachiens; // Contains MachineDto, CreateMachineDto, UpdateMachineDto
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System.IO;
using System;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VendingMachineController : ControllerBase
    {
        private readonly IVendingMachineService _vendingMachineService;
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png" };
        private const int MaxFileSize = 5 * 1024 * 1024; // 5MB
        private readonly IBlobStorageService _blobStorageService;
        private const string VendingMachineContainer = "vendingmachine-images";

        // Constructor injection for the vending machine service
        public VendingMachineController(IVendingMachineService vendingMachineService, IBlobStorageService blobStorageService)
        {
            _vendingMachineService = vendingMachineService;
            _blobStorageService = blobStorageService;
        }

        /// <summary>
        /// Retrieves all vending machines.
        /// </summary>
        [HttpGet]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult<IEnumerable<MachineDto>>> GetAllMachines()
        {
            var machines = await _vendingMachineService.GetAllAsync();
            return Ok(machines);
        }

        /// <summary>
        /// Retrieves a vending machine by its ID.
        /// </summary>
        /// <param name="id">The vending machine ID.</param>
        [HttpGet("{id}")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult<MachineDto>> GetMachine(int id)
        {
            var machine = await _vendingMachineService.GetAsync(id);
            if (machine == null)
                return NotFound("Vending machine not found.");
            return Ok(machine);
        }

        /// <summary>
        /// Creates a new vending machine.
        /// </summary>
        /// <param name="dto">DTO containing machine data for creation.</param>
        [HttpPost]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> CreateMachine([FromBody] CreateMachineDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid machine data.");

            var createdMachine = await _vendingMachineService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetMachine), new { id = createdMachine.MachineId }, createdMachine);
        }

        /// <summary>
        /// Updates an existing vending machine.
        /// </summary>
        /// <param name="id">The vending machine ID.</param>
        /// <param name="dto">DTO containing updated machine data.</param>
        [HttpPut("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<IActionResult> UpdateMachine(int id, [FromBody] UpdateMachineDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid machine data.");

            await _vendingMachineService.UpdateAsync(id, dto);
            return NoContent();
        }

        /// <summary>
        /// Deletes a vending machine by its ID.
        /// </summary>
        /// <param name="id">The vending machine ID.</param>
        [HttpDelete("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<IActionResult> DeleteMachine(int id)
        {
            await _vendingMachineService.DeleteAsync(id);
            return NoContent();
        }

        /// <summary>
        /// Uploads or updates the image for a vending machine.
        /// </summary>
        [HttpPost("{id}/image")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> UploadVendingMachineImage(int id, IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded");

            if (file.Length > MaxFileSize)
                return BadRequest("File size exceeds 5MB limit");

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!_allowedExtensions.Contains(extension))
                return BadRequest("Invalid file type. Only .jpg, .jpeg, and .png files are allowed");

            try
            {
                // Get vending machine
                var machine = await _vendingMachineService.GetAsync(id);
                if (machine == null)
                    return NotFound("Vending machine not found");

                // Delete old image if exists
                if (!string.IsNullOrEmpty(machine.ImagePath))
                {
                    var oldFileName = Path.GetFileName(new Uri(machine.ImagePath).AbsolutePath);
                    await _blobStorageService.DeletePhotoAsync(VendingMachineContainer, oldFileName);
                }

                // Upload new image
                using var stream = file.OpenReadStream();
                var fileName = $"vendingmachine-{id}-{Guid.NewGuid()}{extension}";
                var imageUrl = await _blobStorageService.UploadPhotoAsync(VendingMachineContainer, fileName, stream);

                // Update vending machine with new image path
                var updateDto = new UpdateMachineDto
                {
                    ImagePath = imageUrl
                };
                await _vendingMachineService.UpdateAsync(id, updateDto);

                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }
    }
}
