using MedicalVending.Application.DTOs.Admins;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
     public interface IAdminService :
     ICrudService<AdminDto, CreateAdminDto, UpdateAdminDto, int>
        {
        Task ChangePasswordAsync(int adminId, string currentPassword, string newPassword);
        }
    public interface IAdminAuthService
    {
        //Task<AuthResponseDto> LoginAsync(LoginRequestDto request);
        //Task ChangePasswordAsync(int adminId, string newPassword);
    }

}
