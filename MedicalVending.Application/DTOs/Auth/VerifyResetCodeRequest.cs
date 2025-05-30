using System.ComponentModel.DataAnnotations;

namespace MedicalVending.Application.DTOs.Auth
{
    public class VerifyResetCodeRequest
    {
        [Required]
        [EmailAddress]
        public required string Email { get; set; }
        
        [Required]
        [StringLength(6, MinimumLength = 6)]
        public required string Code { get; set; }
    }
} 