using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Admins
{
    public class CreateAdminDto
    {
        [Required, StringLength(50)]
        public required string AdminName { get; set; }

        [Required, EmailAddress]
        public required string AdminEmail { get; set; }

        [Required, MinLength(8)]
        public required string AdminPass { get; set; } // Only for creation
    }
}
