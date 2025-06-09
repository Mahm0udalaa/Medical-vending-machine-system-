using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.MachineMediciens
{
    public class MachineStockDto
    {
        public int MachineId { get; set; }
        public string MachineLocation { get; set; } = string.Empty;
        public int MedicineId { get; set; }
        public string MedicineName { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string? ImagePath { get; set; }
        public int CategoryId { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal MedicinePrice { get; set; }
        public required string Slot { get; set; }  // Position in the vending machine (1-6)
    }
} 