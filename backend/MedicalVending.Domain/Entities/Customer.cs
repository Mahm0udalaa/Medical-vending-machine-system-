using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Entities
{
    public class Customer
    {
        public int CustomerId { get; set; }
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
        public string? PasswordHash { get; set; }
        public string? CustomerEmail { get; set; }
        public string Role { get; set; } = "Customer"; // Default role
        public int? Age { get; set; }
        public string? ImagePath { get; set; }

        //public IFormFile? image { get; set; } // This property will hold the image file uploaded by the admin
        public virtual ICollection<FavoritesMedicine> FavoritesMedicines { get; set; }
        public virtual ICollection<Purchase> Purchases { get; set; }

        public Customer()
        {
            FavoritesMedicines = new HashSet<FavoritesMedicine>();
            Purchases = new HashSet<Purchase>();
        }
    }
}
