using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.VendingMachiens
{
    public class CreateMachineDto
    {
        [Required]
        public required string Location { get; set; }

        [Required]
        public double Latitude { get; set; }

        [Required]
        public double Longitude { get; set; }

        [Required]
        public required string QR { get; set; }

        [Required]
        public int Capacity { get; set; }

        [Required]
        public int AdminId { get; set; }
    }
} 