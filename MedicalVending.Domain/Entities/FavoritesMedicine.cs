using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Entities
{
    public class FavoritesMedicine
    {
        public int CustomerId { get; set; }
        public int MedicineId { get; set; }
    
        public virtual required Customer Customer { get; set; }
        public virtual required Medicine Medicine { get; set; }
    }
}
