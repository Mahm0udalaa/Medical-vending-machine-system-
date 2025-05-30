using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Categorys
{
    public class CategoryDto
    {
        public int CategoryId { get; set; }
        public required string CategoryName { get; set; }
        public required string Description { get; set; }
        public int MedicineCount { get; set; } // Calculated field
        public string? ImagePath { get; set; }
    }
}
