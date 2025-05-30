using System.ComponentModel.DataAnnotations;

namespace MedicalVending.Application.DTOs.Auth
{
    public class ForgotPasswordRequest
    {
        [Required]
        [EmailAddress]
        public required string Email { get; set; }
    }
} 