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
        [Range(1, 6, ErrorMessage = "Slot must be between 1 and 6")]
        public required string Slot { get; set; }
    }
} 