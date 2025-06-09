using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Entities
{
    public class MachineMedicine
    {
           public int MachineId { get; set; }
           public int MedicineId { get; set; }
           public int Quantity { get; set; }
           public required string Slot { get; set; }  // Position in the vending machine (1-6)
           public virtual VendingMachine? VendingMachine { get; set; }
           public virtual Medicine? Medicine { get; set; }
           public DateTime LastRestocked { get; set; }
    }
}
