using AutoMapper;
using MedicalVending.Application.DTOs.Categorys;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Services
{
    // Service for managing categories
    public class CategoryService : ICategoryService
    {
        private readonly ICategoryRepository _categoryRepository;
        private readonly IMapper _mapper;

        public CategoryService(ICategoryRepository categoryRepository, IMapper mapper)
        {
            _categoryRepository = categoryRepository;
            _mapper = mapper;
        }

        public async Task<IEnumerable<CategoryDto>> GetAllAsync()
        {
            var categories = await _categoryRepository.GetAllAsync();
            return _mapper.Map<IEnumerable<CategoryDto>>(categories);
        }

        //public async Task<CategoryDto?> GetByIdAsync(int id)
        //{
        //    var category = await _categoryRepository.GetByIdAsync(id);
        //    return _mapper.Map<CategoryDto>(category);
        //}

        public async Task<CategoryDto?> GetByIdAsync(int id)
        {
            var category = await _categoryRepository.GetByIdAsync(id);
            if (category == null) return null;

            var dto = _mapper.Map<CategoryDto>(category);
            dto.MedicineCount = category.Medicines?.Count ?? 0;
            return dto;
        }
        public async Task AddAsync(CreateCategoryDto dto)
        {
            var category = _mapper.Map<Category>(dto);
            await _categoryRepository.AddAsync(category);
        }

        public async Task UpdateAsync(int id, UpdateCategoryDto dto)
        {
            var existingCategory = await _categoryRepository.GetByIdAsync(id);
            if (existingCategory == null)
                throw new NotFoundException("Category not found");

            _mapper.Map(dto, existingCategory);
            await _categoryRepository.UpdateAsync(existingCategory);
        }

        public async Task DeleteAsync(int id)
        {
            if (!await _categoryRepository.ExistsAsync(id))
                throw new NotFoundException("Category not found");

            await _categoryRepository.DeleteAsync(id);
        }
    }
}
