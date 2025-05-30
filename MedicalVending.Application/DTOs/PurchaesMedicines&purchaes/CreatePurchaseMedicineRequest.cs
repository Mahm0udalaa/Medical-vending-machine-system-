using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    // API Request (Input)
    public class CreatePurchaseMedicineRequest
    {
      

        [Required]
        public int MedicineId { get; set; }

        [Required, Range(1, 100)]
        public int Quantity { get; set; }

        [Range(0.01, 10000)]
        public decimal PricePerUnit { get; set; }
    }
}
