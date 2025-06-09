using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Entities
{
    public class PurchaseMedicine
    {
        public int PurchaseId { get; set; }
        public int MedicineId { get; set; }
        public int Quantity { get; set; }
        public decimal PricePerUnit { get; set; }
        public decimal TotalPriceUnit { get; set; }
        public virtual Purchase? Purchase { get; set; }
        public virtual Medicine? Medicine { get; set; }
    }
}
