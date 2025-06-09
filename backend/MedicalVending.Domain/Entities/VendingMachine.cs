using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Entities
{
    
       public class VendingMachine
        {
        [Key]
            public required int MachineId { get; set; }
            public required string Location { get; set; }
            public double Latitude { get; set; }
            public double Longitude { get; set; }
            public required string QR { get; set; }
            public int Capacity { get; set; }
            public int AdminId { get; set; }
            public required virtual Admin Admin { get; set; }
            public virtual ICollection<MachineMedicine> MachineMedicines { get; set; }
            public virtual ICollection<Purchase> Purchases { get; set; }
            public string? ImagePath { get; set; }

            public   VendingMachine()
            {
                MachineMedicines = new HashSet<MachineMedicine>();
                Purchases = new HashSet<Purchase>();
            }
        }
}
