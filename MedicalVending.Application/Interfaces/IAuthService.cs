using System.Threading.Tasks;
using MedicalVending.Application.DTOs;
using MedicalVending.Application.DTOs.Auth;
using MedicalVending.Domain.Entities;

namespace MedicalVending.Application.Interfaces
{
    public interface IAuthService
    {
        Task<string> Register(RegisterRequestDto model);
        Task<LoginResponse> Login(LoginRequestDto model);
        Task<LoginResponse> RefreshToken(string refreshToken);
        Task<Customer?> ValidateUserAsync(string email, string password);
        Task<Customer?> GetCustomerByEmailAsync(string email);
        Task<Admin?> GetAdminByEmailAsync(string email);
        Task Logout(string refreshToken);
        Task<bool> RequestPasswordReset(string email);
        Task<bool> ResetPassword(string email, string code, string newPassword);
        Task<bool> VerifyPasswordResetCode(string email, string code);
    }
}
