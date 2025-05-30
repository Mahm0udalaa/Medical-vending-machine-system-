using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Entities
{
    public class Medicine
    {
        public int MedicineId { get; set; }
        public required string MedicineName { get; set; }
        public decimal MedicinePrice { get; set; }
        public string? ImagePath { get; set; } // Path to the stored image file
        public int Stock { get; set; }
        public DateTime ExpirationDate { get; set; } // This property will hold the expiration date of the medicine.
        public required string Description { get; set; }
        public required Category Category { get; set; } // Navigation Property (each Medicine belongs to 1 Category)
        public int CategoryId { get; set; } // Foreign Key
        public virtual ICollection<FavoritesMedicine> FavoritesMedicines { get; set; } //This collection links the medicine to all customers who have marked it as a favorite. مش مقتنع بيها
        public virtual ICollection<MachineMedicine> MachineMedicines { get; set; } //This collection shows which vending machines stock this medicine and in what quantity.
        public virtual ICollection<PurchaseMedicine> PurchaseMedicines { get; set; } //This collection tracks all purchase line items that include this medicine.



        public Medicine()

        {
            FavoritesMedicines = new HashSet<FavoritesMedicine>(); // This collection links the medicine to all customers who have marked it as a favorite.
            MachineMedicines = new HashSet<MachineMedicine>(); //  This collection shows which vending machines stock this medicine and in what quantity.
            PurchaseMedicines = new HashSet<PurchaseMedicine>(); // This collection tracks all purchase line items that include this medicine.
        }
    }
}

