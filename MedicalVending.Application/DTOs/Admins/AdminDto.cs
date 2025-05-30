using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Admins
{
    public class AdminDto
    {
        public int AdminId { get; set; }
        public string AdminName { get; set; } = string.Empty; // Initialize to avoid null
        public string AdminEmail { get; set; } = string.Empty;
    }
}
