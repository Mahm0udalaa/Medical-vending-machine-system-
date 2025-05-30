using MedicalVending.Application.DTOs.Medicines;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System.IO;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MedicineController : ControllerBase
    {
        private readonly IMedicineService _medicineService;
        private readonly IBlobStorageService _blobStorageService;
        private readonly JsonSerializerOptions _jsonOptions;
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png" };
        private const int MaxFileSize = 5 * 1024 * 1024; // 5MB

        public MedicineController(IMedicineService medicineService, IBlobStorageService blobStorageService)
        {
            _medicineService = medicineService;
            _blobStorageService = blobStorageService;
            _jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
        }

        /// <summary>
        /// Retrieves all medicines.
        /// </summary>
        [HttpGet]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult> GetAll()
        {
            var medicines = await _medicineService.GetAllAsync();
            return Ok(medicines);
        }

        /// <summary>
        /// Retrieves a specific medicine by ID.
        /// </summary>
        [HttpGet("{id}")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult> GetById(int id)
        {
            var medicine = await _medicineService.GetByIdAsync(id);
            if (medicine == null)
                return NotFound("Medicine not found.");
            return Ok(medicine);
        }

        /// <summary>
        /// Creates a new medicine with optional image upload.
        /// </summary>
        [HttpPost]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> AddMedicine([FromBody] CreateMedicineDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var medicineId = await _medicineService.AddAsync(dto);
                // Return formatted response matching the desired JSON structure
                var response = new
                {
                    medicineId = medicineId,
                    medicineName = dto.MedicineName,
                    medicinePrice = dto.MedicinePrice,
                    stock = dto.Stock,
                    expirationDate = dto.ExpirationDate,
                    description = dto.Description,
                    categoryId = dto.CategoryId,
                    imagePath = dto.image
                };
                return StatusCode(201, response);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }

        /// <summary>
        /// Updates an existing medicine with optional image upload.
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> UpdateMedicine(int id, [FromBody] UpdateMedicineDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            await _medicineService.UpdateAsync(id, dto);
            
            var medicine = await _medicineService.GetByIdAsync(id);
            return Ok(medicine);
        }

        /// <summary>
        /// Deletes a medicine by ID.
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> DeleteMedicine(int id)
        {
            await _medicineService.DeleteAsync(id);
            return Ok(new { message = "Medicine deleted successfully" });
        }

        /// <summary>
        /// Returns a simplified list of medicines with minimal information.
        /// </summary>
        [HttpGet("simplified")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult> GetSimplifiedList()
        {
            var medicines = await _medicineService.GetSimplifiedListAsync();
            return Ok(medicines);
        }

        /// <summary>
        /// Uploads a medicine image and updates the medicine record.
        /// </summary>
        [HttpPost("{id}/image")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> UploadMedicineImage(int id, IFormFile file)
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
                // Check if medicine exists
                var medicine = await _medicineService.GetByIdAsync(id);
                if (medicine == null)
                    return NotFound("Medicine not found");

                // Upload image to blob storage
                using var stream = file.OpenReadStream();
                var fileName = $"medicine-{id}-{Guid.NewGuid()}{extension}";
                var imageUrl = await _blobStorageService.UploadPhotoAsync("medicine-images", fileName, stream);

                // Update medicine record with image path
                var updateDto = new UpdateMedicineDto
                {
                    image = imageUrl
                };
                await _medicineService.UpdateAsync(id, updateDto);

                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }

        /// <summary>
        /// Updates the image for an existing medicine.
        /// </summary>
        [HttpPut("{id}/image")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> UpdateMedicineImage(int id, IFormFile file)
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
                // Check if medicine exists
                var medicine = await _medicineService.GetByIdAsync(id);
                if (medicine == null)
                    return NotFound("Medicine not found");

                // Delete old image if exists
                if (!string.IsNullOrEmpty(medicine.ImagePath))
                {
                    var oldFileName = Path.GetFileName(new Uri(medicine.ImagePath).AbsolutePath);
                    await _blobStorageService.DeletePhotoAsync("medicine-images", oldFileName);
                }

                // Upload new image
                using var stream = file.OpenReadStream();
                var fileName = $"medicine-{id}-{Guid.NewGuid()}{extension}";
                var imageUrl = await _blobStorageService.UploadPhotoAsync("medicine-images", fileName, stream);

                // Update medicine record with new image path
                var updateDto = new UpdateMedicineDto
                {
                    image = imageUrl
                };
                await _medicineService.UpdateAsync(id, updateDto);

                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }
    }
}
