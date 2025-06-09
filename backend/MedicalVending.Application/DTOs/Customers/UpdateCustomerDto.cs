using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MedicalVending.Domain.Exceptions;

namespace MedicalVending.Application.DTOs.Customers
{
    public class UpdateCustomerDto
    {
        public string? CustomerName { get; set; }

        [EmailAddress]
        public string? CustomerEmail { get; set; }

        [Phone]
        public string? CustomerPhone { get; set; }

        [MinLength(8, ErrorMessage = "Password must be at least 8 characters long")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$", 
            ErrorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character")]
        public string? CustomerPass { get; set; }

        public string? CurrentPassword { get; set; }

        [Range(0, 120, ErrorMessage = "Age must be between 0 and 120")]
        public int? Age { get; set; }
        public string? ImagePath { get; set; }
    }
}
