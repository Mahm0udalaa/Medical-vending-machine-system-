using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.FavoritesMedicines
{
    public class AddFavoriteDto
    {
        [Required]
        public int CustomerId { get; set; }

        [Required]
        public int MedicineId { get; set; }
    }
}
