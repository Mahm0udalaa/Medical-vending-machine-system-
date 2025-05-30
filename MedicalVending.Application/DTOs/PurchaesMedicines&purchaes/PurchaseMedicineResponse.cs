using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    // API Response (Output)
    public class PurchaseMedicineResponse
    {
        public int MedicineId { get; set; }
        public string MedicineName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal PricePerUnit { get; set; }
        public decimal TotalPriceUnit { get; set; }
    }
}
