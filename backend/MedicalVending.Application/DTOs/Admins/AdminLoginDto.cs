using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Admins
{
    class AdminLoginDto
    {
        [Required, EmailAddress]
        public string? AdminEmail { get; set; }

        [Required, MinLength(8)]
        public string? AdminPass { get; set; }
    }
}
