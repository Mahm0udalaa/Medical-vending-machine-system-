using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MedicalVending.Application.DTOs.MachineMediciens;

namespace MedicalVending.Application.DTOs.VendingMachiens
{
    public class MachineDto // Response
    {
        public int MachineId { get; set; }
        public required string Location { get; set; }
        public required string QR { get; set; }
        public int Capacity { get; set; }
        public int AdminId { get; set; }
        public string AdminName { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string? ImagePath { get; set; }
    }
} 