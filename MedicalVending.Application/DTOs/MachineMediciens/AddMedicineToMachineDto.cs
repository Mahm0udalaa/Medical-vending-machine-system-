using System.ComponentModel.DataAnnotations;

namespace MedicalVending.Application.DTOs.MachineMediciens
{
    public class AddMedicineToMachineDto
    {
        [Required] 
        public int MachineId { get; set; }
        
        [Required] 
        public int MedicineId { get; set; }
        
        [Required]
        [Range(0, 1000)]
        public int Quantity { get; set; }
        
        [Required]
        public string Slot { get; set; } = string.Empty;
    }
} 