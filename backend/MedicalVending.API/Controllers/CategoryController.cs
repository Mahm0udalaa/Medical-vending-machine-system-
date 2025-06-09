using MedicalVending.Application.DTOs.Categorys;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System.IO;
using System;
using System.Linq;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly ICategoryService _categoryService;
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png" };
        private const int MaxFileSize = 5 * 1024 * 1024; // 5MB
        private readonly IBlobStorageService _blobStorageService;
        private const string CategoryContainer = "category-images";

        public CategoryController(ICategoryService categoryService, IBlobStorageService blobStorageService)
        {
            _categoryService = categoryService;
            _blobStorageService = blobStorageService;
        }

        /// Retrieves all categories.
        [HttpGet]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult<IEnumerable<object>>> GetCategories()
        {
            var categories = await _categoryService.GetAllAsync();
            var result = categories.Select(c => new {
                c.CategoryId,
                c.CategoryName,
                c.ImagePath
            });
            return Ok(result);
        }

        /// Creates a new category.
        [HttpPost]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> CreateCategory([FromBody] CreateCategoryDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid category data.");

            await _categoryService.AddAsync(dto);
            return StatusCode(201, "Category created successfully.");
        }

       
        /// Updates an existing category.
    
        [HttpPut("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> UpdateCategory(int id, [FromBody] UpdateCategoryDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid category data.");

            await _categoryService.UpdateAsync(id, dto);
            return NoContent();
        }

      
        /// Deletes a category by ID.
       
        [HttpDelete("{id}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> DeleteCategory(int id)
        {
            await _categoryService.DeleteAsync(id);
            return NoContent();
        }

        /// Uploads an image for a category (only if no image exists).
    
        [HttpPost("{id}/image/upload")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> UploadCategoryImage(int id, IFormFile file)
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
                var category = await _categoryService.GetByIdAsync(id);
                if (category == null)
                    return NotFound("Category not found");
                if (!string.IsNullOrEmpty(category.ImagePath))
                    return BadRequest("Image already exists. Use update endpoint.");
                using var stream = file.OpenReadStream();
                var fileName = $"category-{id}-{Guid.NewGuid()}{extension}";
                var imageUrl = await _blobStorageService.UploadPhotoAsync(CategoryContainer, fileName, stream);
                var updateDto = new UpdateCategoryDto { ImagePath = imageUrl };
                await _categoryService.UpdateAsync(id, updateDto);
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }

        /// Updates the image for a category (only if an image already exists).
        [HttpPut("{id}/image/update")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult> UpdateCategoryImage(int id, IFormFile file)
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
                var category = await _categoryService.GetByIdAsync(id);
                if (category == null)
                    return NotFound("Category not found");
                if (string.IsNullOrEmpty(category.ImagePath))
                    return BadRequest("No image exists. Use upload endpoint.");
                // Delete old image
                var oldFileName = Path.GetFileName(new Uri(category.ImagePath).AbsolutePath);
                await _blobStorageService.DeletePhotoAsync(CategoryContainer, oldFileName);
                // Upload new image
                using var stream = file.OpenReadStream();
                var fileName = $"category-{id}-{Guid.NewGuid()}{extension}";
                var imageUrl = await _blobStorageService.UploadPhotoAsync(CategoryContainer, fileName, stream);
                var updateDto = new UpdateCategoryDto { ImagePath = imageUrl };
                await _categoryService.UpdateAsync(id, updateDto);
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, details = ex.InnerException?.Message });
            }
        }
    }
}
