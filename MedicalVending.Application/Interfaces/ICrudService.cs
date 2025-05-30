using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    public interface ICrudService<TDto, TCreateDto, TUpdateDto, TId>
    {
        Task<IEnumerable<TDto>> GetAllAsync();
        Task<TDto?> GetByIdAsync(TId id);
        Task AddAsync(TCreateDto dto);
        Task UpdateAsync(TId id, TUpdateDto dto);
        Task DeleteAsync(TId id);
    }
}
