using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.VendingMachiens
{
    public class UpdateMachineDto
    {
        public string? Location { get; set; }

        
        public double? Latitude { get; set; }

        
        public double? Longitude { get; set; }

       
        public string? QR { get; set; }

       
        public int? Capacity { get; set; }

        public int? AdminId { get; set; }
        public string? ImagePath { get; set; }
    }
} 