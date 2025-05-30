using MedicalVending.Application.DTOs.Categorys;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    

    public interface ICategoryService :
    ICrudService<CategoryDto, CreateCategoryDto, UpdateCategoryDto, int>
    {
        // Optional: Add domain logic like category statistics
    }
}
