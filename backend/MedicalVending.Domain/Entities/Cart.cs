using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalVending.Domain.Entities
{
    public class Cart
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int CustomerId { get; set; }

        [Required]
        public int MachineId { get; set; }

        [Required]
        public int MedicineId { get; set; }

        [Required]
        public int Quantity { get; set; }

        [Required]
        public decimal PricePerUnit { get; set; }

        // Navigation properties
        [ForeignKey("CustomerId")]
        public Customer? Customer { get; set; }

        [ForeignKey("MachineId")]
        public VendingMachine? Machine { get; set; }

        [ForeignKey("MedicineId")]
        public Medicine? Medicine { get; set; }
    }
} 