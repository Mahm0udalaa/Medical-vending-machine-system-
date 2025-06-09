using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    public class PurchaseDto // Response
    {
        public int PurchaseId { get; set; }
        public DateTime PurchaseDate { get; set; }
        public decimal TotalPrice { get; set; }
        public int MachineId { get; set; }
        public int CustomerId { get; set; }
        public required List<PurchaseMedicineResponse> Items { get; set; }
    }
}
