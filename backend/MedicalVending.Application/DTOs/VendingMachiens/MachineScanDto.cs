using System.Collections.Generic;
using MedicalVending.Application.DTOs.MachineMediciens;

namespace MedicalVending.Application.DTOs.VendingMachiens
{
    public class MachineScanDto
    {
        public int MachineId { get; set; }
        public string Location { get; set; } = string.Empty;
        public string? ImagePath { get; set; }
        public IEnumerable<MachineStockDto> Medicines { get; set; } = new List<MachineStockDto>();
    }
} 