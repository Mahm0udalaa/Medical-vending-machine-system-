using System.ComponentModel.DataAnnotations;

namespace MedicalVending.Application.DTOs.Auth
{
    public class SendCodeRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
    }
} 