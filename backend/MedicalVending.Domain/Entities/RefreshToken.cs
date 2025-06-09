using System;

namespace MedicalVending.Domain.Entities
{
    public class RefreshToken
    {
        public int Id { get; set; }
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsRevoked { get; set; }
        public bool IsUsed { get; set; }
        public int? AdminId { get; set; }
        public int? CustomerId { get; set; }
        public Admin? Admin { get; set; }
        public Customer? Customer { get; set; }
    }
} 