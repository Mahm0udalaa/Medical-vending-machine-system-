using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    public interface IEmailVerificationService
    {
        Task SendVerificationCodeAsync(string email);
        Task<bool> VerifyCodeAsync(string email, string code);
    }
} 