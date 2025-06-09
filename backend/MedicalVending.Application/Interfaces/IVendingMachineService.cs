using MedicalVending.Application.DTOs.MachineMediciens;
using MedicalVending.Application.DTOs.VendingMachiens;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    //public interface IVendingMachineService
    //{
    //    Task<IEnumerable<VendingMachine>> GetAllMachinesAsync();
    //    Task<VendingMachine?> GetMachineByIdAsync(int id);
    //    Task AddMachineAsync(VendingMachine machine);
    //    Task UpdateMachineAsync(VendingMachine machine);
    //    Task DeleteMachineAsync(int id);
    //}

    public interface IVendingMachineService 
    {
        Task<MachineDto> GetAsync(int id);
        Task<IEnumerable<MachineDto>> GetAllAsync();
        Task<MachineDto> CreateAsync(CreateMachineDto dto);
        Task UpdateAsync(int id, UpdateMachineDto dto);
        Task DeleteAsync(int id);
        Task<IEnumerable<MachineDto>> GetMachinesByAdminIdAsync(int adminId);

        // Stock Management
        Task<IEnumerable<MachineStockDto>> GetMachineStockAsync(int machineId);
        Task RestockMachineAsync(int machineId, List<UpdateStockDto> updates);

        // Additional Domain Methods (if needed)
       
    }
}
