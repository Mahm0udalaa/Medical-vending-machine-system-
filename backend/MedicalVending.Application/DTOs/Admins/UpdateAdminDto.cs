using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Admins
{
    public class UpdateAdminDto
    {
        [StringLength(50)]
        public string? AdminName { get; set; }

        [EmailAddress]
        public string? AdminEmail { get; set; }

        // For password change
        [MinLength(8)]
        public string? AdminPass { get; set; } // new password
        public string? CurrentPassword { get; set; }
    }
}
