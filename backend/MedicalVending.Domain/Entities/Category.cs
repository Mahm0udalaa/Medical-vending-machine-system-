using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Entities
{
    public class Category
    {
        public int CategoryId { get; set; }
        public required string CategoryName { get; set; }
        public required string Description { get; set; }
        //public IFormFile? image { get; set; } // This property will hold the image file uploaded by the admin
        public required ICollection<Medicine> Medicines { get; set; }
        public string? ImagePath { get; set; }
    }
}
