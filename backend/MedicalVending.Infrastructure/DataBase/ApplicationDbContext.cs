using Microsoft.EntityFrameworkCore;
using MedicalVending.Domain.Entities;
using System.Collections.Generic;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;

namespace MedicalVending.Infrastructure.DataBase
{
    public class ApplicationDbContext : IdentityDbContext<IdentityUser>
    {
        // Constructor
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // DbSet properties for your entities.
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Medicine> Medicines { get; set; }
        public DbSet<VendingMachine> VendingMachines { get; set; }
        public DbSet<Admin> Admins { get; set; }
        public DbSet<FavoritesMedicine> FavoritesMedicines { get; set; }
        public DbSet<MachineMedicine> MachineMedicines { get; set; }
        public DbSet<Purchase> Purchases { get; set; }
        public DbSet<PurchaseMedicine> PurchaseMedicines { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<EmailVerificationCode> EmailVerificationCodes { get; set; }
        public DbSet<Cart> Carts { get; set; }

        // Configure the model using Fluent API.
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Call the base method
            base.OnModelCreating(modelBuilder);

            // Configure EmailVerificationCode
            modelBuilder.Entity<EmailVerificationCode>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.UserId).IsRequired();
                entity.Property(e => e.Code).IsRequired();
                entity.Property(e => e.ExpirationTime).IsRequired();
                entity.HasIndex(e => new { e.UserId, e.ExpirationTime });
            });

            // Column name configuration to match existing database
            modelBuilder.Entity<Customer>(entity =>
            {
                entity.Property(c => c.PasswordHash)
                    .HasColumnName("PasswordHash");
                entity.Property(c => c.Role)
                    .HasColumnName("Role")
                    .HasDefaultValue("Customer"); 
            });

            modelBuilder.Entity<Admin>(entity =>
            {
                entity.Property(a => a.PasswordHash)
                    .HasColumnName("PasswordHash");
                entity.Property(a => a.Role)
                    .HasColumnName("Role")
                    .HasDefaultValue("Admin");
            });

            // --------------------------
            // Configure Composite Keys
            // --------------------------

            // FavoritesMedicine uses a composite key of CustomerId and MedicineId.
            modelBuilder.Entity<FavoritesMedicine>()
                .HasKey(fm => new { fm.CustomerId, fm.MedicineId });

            modelBuilder.Entity<MachineMedicine>()
                .HasKey(mm => new { mm.MachineId, mm.MedicineId });

            modelBuilder.Entity<PurchaseMedicine>()
                .HasKey(pm => new { pm.PurchaseId, pm.MedicineId });

            // --------------------------
            // Configure Relationships
            // --------------------------

            // Customer ↔ FavoritesMedicine (Many-to-Many via join table)
            modelBuilder.Entity<FavoritesMedicine>()
                .HasOne(fm => fm.Customer) // Each FavoritesMedicine belongs to ONE Customer
                .WithMany(c => c.FavoritesMedicines) // A Customer has MANY FavoritesMedicines
                .HasForeignKey(fm => fm.CustomerId); // Foreign key in FavoritesMedicine table points to Customer
            modelBuilder.Entity<FavoritesMedicine>()
                .HasOne(fm => fm.Medicine)
                .WithMany(m => m.FavoritesMedicines)
                .HasForeignKey(fm => fm.MedicineId);

            // VendingMachine ↔ MachineMedicine (Many-to-Many via join table)
            modelBuilder.Entity<MachineMedicine>()
                .HasOne(mm => mm.VendingMachine)
                .WithMany(vm => vm.MachineMedicines)
                .HasForeignKey(mm => mm.MachineId);

            modelBuilder.Entity<MachineMedicine>()
                .HasOne(mm => mm.Medicine)
                .WithMany(m => m.MachineMedicines)
                .HasForeignKey(mm => mm.MedicineId);

            modelBuilder.Entity<PurchaseMedicine>()
                .HasOne(pm => pm.Purchase)
                .WithMany(p => p.PurchaseMedicines)
                .HasForeignKey(pm => pm.PurchaseId);

            modelBuilder.Entity<PurchaseMedicine>()
                .HasOne(pm => pm.Medicine)
                .WithMany(m => m.PurchaseMedicines)
                .HasForeignKey(pm => pm.MedicineId);

            modelBuilder.Entity<PurchaseMedicine>()
                .Property(pm => pm.PricePerUnit)
                .HasPrecision(18, 4);

            modelBuilder.Entity<PurchaseMedicine>()
                .Property(pm => pm.TotalPriceUnit)
                .HasPrecision(18, 4);

            modelBuilder.Entity<Purchase>()
                .HasOne(p => p.Customer)
                .WithMany(c => c.Purchases)
                .HasForeignKey(p => p.CustomerId);

            modelBuilder.Entity<Purchase>()
                .HasOne(p => p.VendingMachine)
                .WithMany(vm => vm.Purchases)
                .HasForeignKey(p => p.MachineId);

            modelBuilder.Entity<Purchase>()
                .Property(p => p.TotalPrice)
                .HasPrecision(18, 4);

            modelBuilder.Entity<VendingMachine>()
                .HasOne(vm => vm.Admin)
                .WithMany(a => a.VendingMachines)
                .HasForeignKey(vm => vm.AdminId);

            modelBuilder.Entity<Medicine>()
                .HasOne(m => m.Category)
                .WithMany(c => c.Medicines)
                .HasForeignKey(m => m.CategoryId);

            modelBuilder.Entity<Medicine>()
                .Property(m => m.MedicinePrice)
                .HasPrecision(18, 4);

            modelBuilder.Entity<RefreshToken>()
                .HasOne(r => r.Admin)
                .WithMany()
                .HasForeignKey(r => r.AdminId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<RefreshToken>()
                .HasOne(r => r.Customer)
                .WithMany()
                .HasForeignKey(r => r.CustomerId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Cart relationships
            modelBuilder.Entity<Cart>()
                .HasOne(c => c.Customer)
                .WithMany()
                .HasForeignKey(c => c.CustomerId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Cart>()
                .HasOne(c => c.Machine)
                .WithMany()
                .HasForeignKey(c => c.MachineId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Cart>()
                .HasOne(c => c.Medicine)
                .WithMany()
                .HasForeignKey(c => c.MedicineId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Cart>()
                .Property(c => c.PricePerUnit)
                .HasPrecision(18, 4);
        }
    }
}

