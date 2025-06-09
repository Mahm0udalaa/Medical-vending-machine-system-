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
using MedicalVending.Domain.Exceptions;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MedicineController : ControllerBase
    {
        private readonly IMedicineService _medicineService;
        private readonly IBlobStorageService _blobStorageService;
        private readonly JsonSerializerOptions _jsonOptions;
        private readonly HashSet<string> _allowedExtensions = new() { ".jpg", ".jpeg", ".png" };
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
        public async Task<ActionResult<IEnumerable<MedicineDto>>> GetAll()
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
            try
            {
                var medicine = await _medicineService.GetByIdAsync(id);
                return Ok(medicine);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
        }

        /// <summary>
        /// Creates a new medicine with optional image upload.
        /// </summary>
        [HttpPost]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> AddMedicine([FromForm] CreateMedicineDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            string? imageUrl = null;
            try
            {
                if (dto.ImageFile != null)
                {
                    if (dto.ImageFile.Length > MaxFileSize)
                        return BadRequest("File size exceeds 5MB limit");

                    var extension = Path.GetExtension(dto.ImageFile.FileName).ToLowerInvariant();
                    if (!_allowedExtensions.Contains(extension))
                        return BadRequest("Invalid file type. Only .jpg, .jpeg, and .png files are allowed");

                    using var stream = dto.ImageFile.OpenReadStream();
                    var fileName = $"medicine-{Guid.NewGuid()}{extension}";
                    imageUrl = await _blobStorageService.UploadPhotoAsync("medicine-images", fileName, stream);
                }

                var medicineId = await _medicineService.AddAsync(dto, imageUrl);
                var response = new
                {
                    medicineId = medicineId,
                    medicineName = dto.MedicineName,
                    medicinePrice = dto.MedicinePrice,
                    stock = dto.Stock,
                    expirationDate = dto.ExpirationDate,
                    description = dto.Description,
                    categoryId = dto.CategoryId,
                    imagePath = imageUrl
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
        public async Task<ActionResult<MedicineDto>> UpdateMedicine(int id, [FromForm] UpdateMedicineDto dto)
        {
            string? imageUrl = null;
            if (dto.ImageFile != null)
            {
                var extension = Path.GetExtension(dto.ImageFile.FileName);
                using var stream = dto.ImageFile.OpenReadStream();
                var fileName = $"medicine-{id}-{Guid.NewGuid()}{extension}";
                imageUrl = await _blobStorageService.UploadPhotoAsync("medicine-images", fileName, stream);
            }

            try
            {
                await _medicineService.UpdateAsync(id, dto, imageUrl);
                var medicine = await _medicineService.GetByIdAsync(id);
                return Ok(medicine);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }

        /// <summary>
        /// Deletes a medicine by ID.
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> DeleteMedicine(int id)
        {
            try
            {
                await _medicineService.DeleteAsync(id);
                return Ok(new { message = "Medicine deleted successfully" });
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
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

        [HttpGet("machine/{machineId}")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult> GetMedicinesForMachine(int machineId)
        {
            try
            {
                var medicines = await _medicineService.GetMedicinesForMachineAsync(machineId);
                return Ok(medicines);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
