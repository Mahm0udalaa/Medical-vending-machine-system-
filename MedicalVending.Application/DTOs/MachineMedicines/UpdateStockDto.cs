using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.MachineMediciens
{
    public class UpdateStockDto
    {
        [Required] public int MachineId { get; set; }
        [Required] public int MedicineId { get; set; }
        [Range(0, 1000)] public int Quantity { get; set; }
    }
}
