using System.ComponentModel.DataAnnotations;

namespace MedicalVending.Application.DTOs
{
    public class RegisterRequestDto
    {
        [Required]
        public required string Username { get; set; }
        
        [Required]
        [EmailAddress]
        public required string Email { get; set; }
        
        [Required]
        [MinLength(8, ErrorMessage = "Password must be at least 8 characters long")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$", 
            ErrorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character")]
        public required string Password { get; set; }
        
        [Phone]
        public string Phone { get; set; } = string.Empty;
        
        [Range(0, 120, ErrorMessage = "Age must be between 0 and 120")]
        public int? Age { get; set; }
        
        public string Role { get; set; } = "Customer"; // Default role
    }
}
