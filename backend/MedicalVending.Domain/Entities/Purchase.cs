using System;
using System.Collections.Generic;

namespace MedicalVending.Domain.Entities
{
    public class Purchase
    {
        public int PurchaseId { get; set; }
        public required int MachineId { get; set; }
        public int CustomerId { get; set; }
        public int Quantity { get; set; }
        public DateTime PurchaseDate { get; set; }
        public decimal TotalPrice { get; set; }
        public virtual Customer? Customer { get; set; }
        public virtual VendingMachine? VendingMachine { get; set; }
        public  virtual ICollection<PurchaseMedicine> PurchaseMedicines { get; set; }
        public required virtual ICollection<Medicine> Medicines { get; set; }

        public Purchase()
        {
            PurchaseMedicines = new HashSet<PurchaseMedicine>();
        }
    }
}
