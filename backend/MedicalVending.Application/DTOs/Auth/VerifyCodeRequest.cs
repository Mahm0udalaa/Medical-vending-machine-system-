using System.ComponentModel.DataAnnotations;

namespace MedicalVending.Application.DTOs.Auth
{
    public class VerifyCodeRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        [StringLength(6, MinimumLength = 6)]
        public string Code { get; set; }
    }
} 