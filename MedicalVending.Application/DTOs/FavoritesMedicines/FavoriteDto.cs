using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.FavoritesMedicines
{
    public class FavoriteDto
    {
        public int MedicineId { get; set; }
        public string MedicineName { get; set; } = string.Empty;
        public decimal MedicinePrice { get; set; }
        public DateTime AddedDate { get; set; }
        public string ImagePath { get; set; } = string.Empty;
    }

}
