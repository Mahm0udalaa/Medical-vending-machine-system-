using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Medicines
{
    public class MedicineDto
    {
        public int MedicineId { get; set; }
        public required string MedicineName { get; set; }
        public decimal MedicinePrice { get; set; }
        public string? ImagePath { get; set; }
        public int Stock { get; set; }
        public DateTime ExpirationDate { get; set; }
        public required string Description { get; set; }
        public required string CategoryName { get; set; } // Flattened from Category
    }
}
