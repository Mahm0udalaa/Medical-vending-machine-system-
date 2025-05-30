using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Domain.Attributes
{
    public sealed class FutureDateAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(
            object? value,
            ValidationContext validationContext)
        {
            if (value is null)
                return new ValidationResult("Date cannot be null");

            if (value is DateTime date)
            {
                return date > DateTime.UtcNow
                    ? ValidationResult.Success
                    : new ValidationResult("Date must be in the future");
            }

            return new ValidationResult("Invalid date format");
        }
    }
}

