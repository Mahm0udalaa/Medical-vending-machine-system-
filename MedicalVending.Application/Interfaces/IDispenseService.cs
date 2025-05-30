using System.Threading.Tasks;
using MedicalVending.Application.DTOs;

namespace MedicalVending.Application.Interfaces
{
    public interface IDispenseService
    {
        Task<DispenseResponse> DispenseMedicineAsync(DispenseRequest request);
    }
} 