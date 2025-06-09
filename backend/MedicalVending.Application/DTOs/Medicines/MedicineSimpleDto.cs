using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Medicines
{
    public class MedicineSimpleDto // For lists
    {
        public int MedicineId { get; set; }
        public string? MedicineName { get; set; }
        public decimal MedicinePrice { get; set; }
        public string? ImagePath { get; set; }
    }//delete
}
