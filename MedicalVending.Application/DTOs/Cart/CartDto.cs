namespace MedicalVending.Application.DTOs.Cart
{
    public class CartDto
    {
        public int Id { get; set; }
        public int MedicineId { get; set; }
        public int Quantity { get; set; }
        public string? MedicineName { get; set; }
        public decimal Price { get; set; }
        public string? ImagePath { get; set; }
        public string? Slot { get; set; }
    }
} 