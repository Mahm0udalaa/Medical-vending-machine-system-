using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes; // Contains PurchaseDto, PurchaseStatsDto
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PurchaseController : ControllerBase
    {
        private readonly IPurchaseService _purchaseService;

        public PurchaseController(IPurchaseService purchaseService)
        {
            _purchaseService = purchaseService;
        }

        /// <summary>
        /// Gets a specific purchase by its ID, including details like purchased items.
        /// </summary>
        [HttpGet("{id}")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult<PurchaseDto>> GetPurchaseById(int id)
        {
            var purchase = await _purchaseService.GetPurchaseDetailsAsync(id);
            if (purchase == null)
                return NotFound("Purchase record not found.");

            return Ok(purchase);
        }

        /// <summary>
        /// Gets all purchases for a specific customer.
        /// </summary>
        [HttpGet("customer/{customerId}")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult<IEnumerable<PurchaseDto>>> GetCustomerPurchases(int customerId)
        {
            var purchases = await _purchaseService.GetCustomerPurchasesAsync(customerId);
            return Ok(purchases);
        }

        /// <summary>
        /// Gets all purchases, optionally filtered by date range (UTC).
        /// </summary>
        /// <param name="fromDate">Optional start date (UTC).</param>
        /// <param name="toDate">Optional end date (UTC).</param>
        [HttpGet]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult<IEnumerable<PurchaseDto>>> GetAllPurchases([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var purchases = await _purchaseService.GetAllPurchasesAsync(fromDate, toDate);
            return Ok(purchases);
        }

        /// <summary>
        /// Gets purchase statistics (total revenue, total sales) over an optional date range.
        /// </summary>
        /// <param name="fromDate">Optional start date (UTC).</param>
        /// <param name="toDate">Optional end date (UTC).</param>
        [HttpGet("stats")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult<PurchaseStatsDto>> GetPurchaseStats([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var stats = await _purchaseService.GetPurchaseStatsAsync(fromDate, toDate);
            return Ok(stats);
        }

        /// <summary>
        /// Admin-only endpoint to get detailed purchase reports
        /// </summary>
        [HttpGet("admin-report")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<ActionResult<IEnumerable<AdminPurchaseDto>>> GetAdminReport([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var report = await _purchaseService.GetAdminPurchaseReportAsync(fromDate, toDate);
            return Ok(report);
        }

        /// <summary>
        /// Checkout the cart for a given customer ID and create a purchase
        /// </summary>
        [HttpPost("checkout")]
        [Authorize(Policy = "AllUsers")]
        public async Task<IActionResult> CheckoutCart([FromBody] CheckoutCartRequestDto request)
        {
            if (request == null || request.CustomerId <= 0)
                return BadRequest("Invalid customer ID.");

            var purchase = await _purchaseService.CheckoutCartAsync(request.CustomerId);
            return Ok(purchase);
        }
    }
}
