using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PurchaseMedicineController : ControllerBase
    {
        private readonly IPurchaseMedicineService _purchaseMedicineService;

        public PurchaseMedicineController(IPurchaseMedicineService purchaseMedicineService)
        {
            _purchaseMedicineService = purchaseMedicineService;
        }

        /// <summary>
        /// Retrieves all medicine items for a specific purchase.
        /// </summary>
        [HttpGet("{purchaseId}/items")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult<IEnumerable<PurchaseMedicineResponse>>> GetItemsByPurchase(int purchaseId)
        {
            var items = await _purchaseMedicineService.GetItemsByPurchaseAsync(purchaseId);
            return Ok(items);
        }

        /// <summary>
        /// Add multiple purchased medicine items to a purchase.
        /// </summary>
        /// <param name="purchaseId">The ID of the purchase</param>
        /// <param name="items">List of medicines to add</param>
        /// <returns>HTTP 201 Created on success</returns>
        [HttpPost("{purchaseId}/items")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<IActionResult> AddBulkItems(int purchaseId, [FromBody] List<CreatePurchaseMedicineRequest> items)
        {
            if (items == null || items.Count == 0)
                return BadRequest("Items list cannot be empty.");

            await _purchaseMedicineService.AddBulkItemsAsync(purchaseId, items);
            return StatusCode(201, "Purchase medicine items added successfully.");
        }
    }
}
