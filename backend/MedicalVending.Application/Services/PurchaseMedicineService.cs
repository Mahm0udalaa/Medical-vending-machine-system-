using AutoMapper;
using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.Application.Services
{
    public class PurchaseMedicineService : IPurchaseMedicineService
    {
        private readonly IPurchaseMedicineRepository _repository;
        private readonly IPurchaseRepository _purchaseRepository;
        private readonly IMedicineRepository _medicineRepository;
        private readonly IMapper _mapper;

        public PurchaseMedicineService(
            IPurchaseMedicineRepository repository,
            IPurchaseRepository purchaseRepository,
            IMedicineRepository medicineRepository,
            IMapper mapper)
        {
            _repository = repository;
            _purchaseRepository = purchaseRepository;
            _medicineRepository = medicineRepository;
            _mapper = mapper;
        }

        // 1. Add items to purchase (essential for checkout)
        public async Task AddBulkItemsAsync(int purchaseId, List<CreatePurchaseMedicineRequest> items)
        {
            // Validation
            if (items?.Any() != true)
                throw new BadRequestException("Items list cannot be empty");

            if (!await _purchaseRepository.ExistsAsync(purchaseId))
                throw new NotFoundException("Purchase not found");

            // Validate medicines
            var medicineIds = items.Select(i => i.MedicineId).Distinct();
            var existingMedicines = await _medicineRepository.GetByIdsAsync(medicineIds);

            if (existingMedicines.Count() != medicineIds.Count())
            {
                var missingIds = medicineIds.Except(existingMedicines.Select(m => m.MedicineId));
                throw new NotFoundException($"Medicines not found: {string.Join(",", missingIds)}");
            }

            // Create entities
            var entities = items.Select(item => new PurchaseMedicine
            {
                PurchaseId = purchaseId,
                MedicineId = item.MedicineId,
                Quantity = item.Quantity,
                PricePerUnit = item.PricePerUnit,
                TotalPriceUnit = item.Quantity * item.PricePerUnit
            }).ToList();

            await _repository.AddRangeAsync(entities);
        }

       

        // 2. Get items by purchase (essential for order details)
        public async Task<IEnumerable<PurchaseMedicineResponse>> GetItemsByPurchaseAsync(int purchaseId)
        {
            var items = await _repository.GetByPurchaseAsync(purchaseId);
            return _mapper.Map<IEnumerable<PurchaseMedicineResponse>>(items);
        }
    }
}
