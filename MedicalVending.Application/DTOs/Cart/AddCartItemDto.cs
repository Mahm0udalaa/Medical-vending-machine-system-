namespace MedicalVending.Application.DTOs.Cart
{
    public class AddCartItemDto
    {
        public int CustomerId { get; set; }
        public int MachineId { get; set; }
        public int MedicineId { get; set; }
        public int Quantity { get; set; }
    }
} 