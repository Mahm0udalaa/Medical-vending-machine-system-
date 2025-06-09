using AutoMapper;
using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.PortableExecutable;
using System.Threading.Tasks;

namespace MedicalVending.Application.Services
{
    public class PurchaseService : IPurchaseService
    {
        private readonly IPurchaseRepository _purchaseRepository;
        private readonly IVendingMachineRepository _machineRepository;
        private readonly IPurchaseMedicineService _purchaseMedicineService;
        private readonly ICustomerRepository _customerRepository;
        private readonly IMedicineRepository _medicineRepository;
        private readonly IMapper _mapper;
        private readonly ICartRepository _cartRepository;

        public PurchaseService(
            IPurchaseRepository purchaseRepository,
            IVendingMachineRepository machineRepository,
            ICustomerRepository customerRepository,
            IMedicineRepository medicineRepository,
            IPurchaseMedicineService purchaseMedicineService,
            IMapper mapper,
            ICartRepository cartRepository)
        {
            _purchaseRepository = purchaseRepository;
            _machineRepository = machineRepository;
            _purchaseMedicineService = purchaseMedicineService;
            _customerRepository = customerRepository;
            _medicineRepository = medicineRepository;
            _mapper = mapper;
            _cartRepository = cartRepository;
        }

        public async Task<PurchaseDto> CheckoutAsync(CreatePurchaseDto dto, int customerId) // Accept customerId as parameter
        {
           // 1. Validate machine exists
           var machine = await _machineRepository.GetByIdAsync(dto.MachineId)
               ?? throw new NotFoundException("Vending machine not found");

           // 2. Validate customer exists
           var customer = await _customerRepository.GetByIdAsync(customerId)
               ?? throw new NotFoundException("Customer not found");

           // 3. Validate all medicines exist
           var medicineIds = dto.Items.Select(i => i.MedicineId).Distinct().ToList();
           var medicines = await _medicineRepository.GetByIdsAsync(medicineIds);
           var missingMedicines = medicineIds.Except(medicines.Select(m => m.MedicineId)).ToList();
           if (missingMedicines.Any())
           {
               throw new NotFoundException($"Medicines not found: {string.Join(", ", missingMedicines)}");
           }

           // 4. Create purchase with medicines
           var purchase = new Purchase
           {
               PurchaseDate = DateTime.UtcNow,
               MachineId = dto.MachineId,
               CustomerId = customerId,
               TotalPrice = dto.Items.Sum(i => i.Quantity * i.PricePerUnit),
               VendingMachine = machine,
               Customer = customer,
               Medicines = (ICollection<Medicine>)medicines,
               PurchaseMedicines = dto.Items.Select(item => new PurchaseMedicine
               {
                   MedicineId = item.MedicineId,
                   Quantity = item.Quantity,
                   PricePerUnit = item.PricePerUnit,
                   Medicine = medicines.First(m => m.MedicineId == item.MedicineId)
               }).ToList()
           };

           await _purchaseRepository.AddAsync(purchase);
           // There is no SaveChangesAsync in the interface, so we assume AddAsync persists changes

           return await GetPurchaseDetailsAsync(purchase.PurchaseId);
        }

        public async Task<PurchaseDto> GetPurchaseDetailsAsync(int id)
        {
            var purchase = await _purchaseRepository.GetByIdAsync(id)
                ?? throw new NotFoundException("Purchase not found");

            return new PurchaseDto
            {
                PurchaseId = purchase.PurchaseId,
                PurchaseDate = purchase.PurchaseDate,
                TotalPrice = purchase.TotalPrice,
                MachineId = purchase.MachineId,
                CustomerId = purchase.CustomerId,
                Items = (await _purchaseMedicineService.GetItemsByPurchaseAsync(id)).ToList()
            };
        }

        public async Task<IEnumerable<PurchaseDto>> GetCustomerPurchasesAsync(int customerId)
        {
            var purchases = await _purchaseRepository.GetByCustomerAsync(customerId);
            var result = new List<PurchaseDto>();
            foreach (var p in purchases)
            {
                result.Add(await GetPurchaseDetailsAsync(p.PurchaseId));
            }
            return result;
        }

        public async Task<IEnumerable<PurchaseDto>> GetAllPurchasesAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            var purchases = await _purchaseRepository.GetAllAsync(fromDate, toDate);

            return await Task.WhenAll(purchases.Select(async p =>
                new PurchaseDto
                {
                    PurchaseId = p.PurchaseId,
                    PurchaseDate = p.PurchaseDate,
                    TotalPrice = p.TotalPrice,
                    MachineId = p.MachineId,
                    Items = (await _purchaseMedicineService.GetItemsByPurchaseAsync(p.PurchaseId)).ToList()
                }));
        }

        public async Task<PurchaseStatsDto> GetPurchaseStatsAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            var totalRevenueTask = _purchaseRepository.GetTotalRevenueAsync(fromDate, toDate);
            var totalSalesTask = _purchaseRepository.GetTotalSalesCountAsync(fromDate, toDate);

            await Task.WhenAll(totalRevenueTask, totalSalesTask);

            return new PurchaseStatsDto(
                TotalRevenue: await totalRevenueTask,
                TotalSales: await totalSalesTask,
                FromDate: fromDate,
                ToDate: toDate
            );
        }

        public async Task<IEnumerable<AdminPurchaseDto>> GetAdminPurchaseReportAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            // Get purchases with customer and machine data included for the admin report
            var purchases = await _purchaseRepository.GetAllWithDetailsAsync(fromDate, toDate);
            
            // Use mapper to convert to AdminPurchaseDto
            var adminReportItems = new List<AdminPurchaseDto>();
            
            foreach (var purchase in purchases)
            {
                // Get detailed purchase items
                var items = await _purchaseMedicineService.GetItemsByPurchaseAsync(purchase.PurchaseId);
                
                // Create admin purchase report item
                var adminPurchase = new AdminPurchaseDto(
                    PurchaseId: purchase.PurchaseId,
                    PurchaseDate: purchase.PurchaseDate,
                    TotalPrice: purchase.TotalPrice,
                    MachineLocation: purchase.VendingMachine?.Location ?? "Unknown Location",
                    CustomerId: purchase.CustomerId,
                    CustomerName: purchase.Customer?.CustomerName ?? "Unknown Customer",
                    Items: items
                );
                
                adminReportItems.Add(adminPurchase);
            }
            
            return adminReportItems;
        }

        public async Task<PurchaseDto> CheckoutCartAsync(int customerId)
        {
            // 1. Get all cart items for the user
            var cartItems = await _cartRepository.GetCartItemsByCustomerAsync(customerId);
            if (cartItems == null || !cartItems.Any())
                throw new BadRequestException("Cart is empty.");

            // 2. Validate all items are from the same machine
            var machineId = cartItems.First().MachineId;
            if (cartItems.Any(c => c.MachineId != machineId))
                throw new BadRequestException("All cart items must be from the same vending machine.");

            // 3. Validate machine and customer
            var machine = await _machineRepository.GetByIdAsync(machineId)
                ?? throw new NotFoundException("Vending machine not found");
            var customer = await _customerRepository.GetByIdAsync(customerId)
                ?? throw new NotFoundException("Customer not found");

            // 4. Get latest versions for all medicines
            var medicineIds = cartItems.Select(c => c.MedicineId).Distinct().ToList();
            var medicines = (await _medicineRepository.GetByIdsAsync(medicineIds)).ToList();
            var missingMedicines = medicineIds.Except(medicines.Select(m => m.MedicineId)).ToList();
            if (missingMedicines.Any())
                throw new NotFoundException($"Medicines not found: {string.Join(", ", missingMedicines)}");

            // 5. Create purchase
            var purchase = new Purchase
            {
                PurchaseDate = DateTime.UtcNow,
                MachineId = machineId,
                CustomerId = customerId,
                TotalPrice = 0, // will calculate below
                Medicines = medicines,
                PurchaseMedicines = new List<PurchaseMedicine>()
            };

            decimal total = 0;
            foreach (var item in cartItems)
            {
                var medicine = medicines.First(m => m.MedicineId == item.MedicineId);
                var pricePerUnit = medicine.MedicinePrice;
                var totalPriceUnit = pricePerUnit * item.Quantity;
                total += totalPriceUnit;

                purchase.PurchaseMedicines.Add(new PurchaseMedicine
                {
                    MedicineId = item.MedicineId,
                    Quantity = item.Quantity,
                    PricePerUnit = pricePerUnit,
                    TotalPriceUnit = totalPriceUnit,
                    Medicine = medicine
                });
            }
            purchase.TotalPrice = total;

            await _purchaseRepository.AddAsync(purchase);
            // Remove cart items
            await _cartRepository.RemoveCartItemsAsync(cartItems);

            return await GetPurchaseDetailsAsync(purchase.PurchaseId);
        }

        public async Task<IEnumerable<PurchaseDto>> GetMachinePurchasesAsync(int machineId)
        {
            var purchases = await _purchaseRepository.GetByMachineAsync(machineId);
            var result = new List<PurchaseDto>();
            foreach (var p in purchases)
            {
                result.Add(await GetPurchaseDetailsAsync(p.PurchaseId));
            }
            return result;
        }
    }
}
