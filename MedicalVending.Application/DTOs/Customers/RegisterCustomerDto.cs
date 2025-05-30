using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Customers
{
    public class RegisterCustomerDto
    {
        [Required, EmailAddress]
        public required string CustomerEmail { get; set; }

        [Required, MinLength(8)]
        public required string CustomerPass { get; set; }

        [Required, StringLength(50)]
        public required string CustomerName { get; set; }

        [Phone]
        public string? CustomerPhone { get; set; }

        [Range(0, 120, ErrorMessage = "Age must be between 0 and 120")]
        public int? Age { get; set; }
    }
}
