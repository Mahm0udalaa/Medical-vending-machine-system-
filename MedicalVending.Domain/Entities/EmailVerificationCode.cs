using System;

namespace MedicalVending.Domain.Entities
{
    public class EmailVerificationCode
    {
        public int Id { get; set; }
        public string? UserId { get; set; }
        public string? Code { get; set; }
        public DateTime ExpirationTime { get; set; }
    }
} 