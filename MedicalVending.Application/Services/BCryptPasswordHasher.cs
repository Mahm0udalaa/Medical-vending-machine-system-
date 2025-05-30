using Microsoft.AspNetCore.Identity;
using MedicalVending.Domain.Entities;

namespace MedicalVending.Application.Services
{
    public class BCryptPasswordHasher : IPasswordHasher<Customer>
    {
        public string HashPassword(Customer user, string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        public PasswordVerificationResult VerifyHashedPassword(Customer user, string hashedPassword, string providedPassword)
        {
            if (BCrypt.Net.BCrypt.Verify(providedPassword, hashedPassword))
                return PasswordVerificationResult.Success;
            return PasswordVerificationResult.Failed;
        }
    }
} 