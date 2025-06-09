using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.Categorys
{
    public class UpdateCategoryDto
    {
        [StringLength(50)]
        public string? CategoryName { get; set; }

        [StringLength(200)]
        public string? Description { get; set; }

        public string? ImagePath { get; set; }
    }
}
