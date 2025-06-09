using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    public class CreatePurchaseDto
    {
        [Required]
        public int MachineId { get; set; }
        [Required]
        public int CustomerId { get; set; }

        [Required]
        public required List<CreatePurchaseMedicineRequest> Items { get; set; }
    }
}
