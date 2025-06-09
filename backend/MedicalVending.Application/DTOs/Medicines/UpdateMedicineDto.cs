using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MedicalVending.Domain.Attributes;
using Microsoft.AspNetCore.Http;

namespace MedicalVending.Application.DTOs.Medicines
{
   public class UpdateMedicineDto
    {
        [StringLength(100)]
        public string? MedicineName { get; set; }

        [Range(0.01, 1000)]
        public decimal? MedicinePrice { get; set; }

        [Range(0, int.MaxValue)]
        public int? Stock { get; set; }

        [FutureDate]
        public DateTime? ExpirationDate { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }
        
        // Optional image upload
        public IFormFile? ImageFile { get; set; }

        public int? CategoryId { get; set; }
    }
}
