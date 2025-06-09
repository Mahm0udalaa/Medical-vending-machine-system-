namespace MedicalVending.Domain.Entities
{
    public class Admin
    {
        public int AdminId { get; set; }
        public string? AdminName { get; set; }
        public string? AdminEmail { get; set; }
        public string? PasswordHash { get; set; }
        public string Role { get; set; } = "Admin"; // Default role
        public virtual ICollection<VendingMachine> VendingMachines { get; set; } = new HashSet<VendingMachine>();
    }
}
