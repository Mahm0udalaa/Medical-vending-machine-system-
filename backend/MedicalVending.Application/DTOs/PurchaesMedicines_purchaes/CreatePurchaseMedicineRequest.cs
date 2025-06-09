namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    public class CreatePurchaseMedicineRequest
    {
        public int MedicineId { get; set; }
        public int Quantity { get; set; }
        public decimal PricePerUnit { get; set; }
    }
} 