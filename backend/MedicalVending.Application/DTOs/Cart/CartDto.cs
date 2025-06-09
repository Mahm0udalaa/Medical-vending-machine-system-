namespace MedicalVending.Application.DTOs.Cart
{
    public class CartDto
    {
        public int Id { get; set; }
        public int MachineId { get; set; }
        public string MachineLocation { get; set; } = string.Empty;
        public int MedicineId { get; set; }
        public int Quantity { get; set; }
        public string? MedicineName { get; set; }
        public decimal Price { get; set; }
        public string? ImagePath { get; set; }
        public required string Slot { get; set; }
    }
} 