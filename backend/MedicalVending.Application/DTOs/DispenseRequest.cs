using System.ComponentModel.DataAnnotations;

namespace MedicalVending.Application.DTOs
{
    public class DispenseRequest
    {
        [Required]
        public string DeviceId { get; set; } = string.Empty;

        [Required]
        public int MedicineId { get; set; }

        [Required]
        [Range(1, 10, ErrorMessage = "Quantity must be between 1 and 10")]
        public int Quantity { get; set; }
    }
} 