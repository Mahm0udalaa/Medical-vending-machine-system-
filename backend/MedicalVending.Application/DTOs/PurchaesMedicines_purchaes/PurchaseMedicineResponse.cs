namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    public class PurchaseMedicineResponse
    {
        public int MedicineId { get; set; }
        public int? VersionId { get; set; }
        public string MedicineName { get; set; }
        public decimal PricePerUnit { get; set; }
        public int Quantity { get; set; }
        public decimal TotalPriceUnit { get; set; }
        public string? ImagePath { get; set; }
    }
} 