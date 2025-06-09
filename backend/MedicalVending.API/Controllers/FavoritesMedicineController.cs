using MedicalVending.Application.DTOs.FavoritesMedicines;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize(Policy = "CustomerOnly")]
    public class FavoritesMedicineController : ControllerBase
    {
        private readonly IFavoritesMedicineService _favoritesService;

        // Constructor injection for the FavoritesMedicine service
        public FavoritesMedicineController(IFavoritesMedicineService favoritesService)
        {
            _favoritesService = favoritesService;
        }

        /// <summary>
        /// Retrieves all favorite medicines for a specific customer.
        /// </summary>
        /// <param name="customerId">The ID of the customer</param>
        /// <returns>List of FavoriteDto objects</returns>
        [HttpGet("{customerId}")]
        public async Task<ActionResult<IEnumerable<FavoriteDto>>> GetFavoritesByCustomer(int customerId)
        {
            var favorites = await _favoritesService.GetCustomerFavoritesAsync(customerId);
            return Ok(favorites); // Returns 200 OK with the list of favorites
        }

        /// <summary>
        /// Adds a medicine to a customer's favorites.
        /// </summary>
        /// <param name="dto">DTO containing CustomerId and MedicineId</param>
        /// <returns>Status 201 if created</returns>
        [HttpPost]
        public async Task<IActionResult> AddFavorite([FromBody] AddFavoriteDto dto)
        {
            if (dto == null)
                return BadRequest("Invalid favorite data.");

            await _favoritesService.AddFavoriteAsync(dto);
            return StatusCode(201, "Favorite added successfully.");
        }

        /// <summary>
        /// Removes a medicine from a customer's favorites.
        /// </summary>
        /// <param name="customerId">Customer ID (as query parameter)</param>
        /// <param name="medicineId">Medicine ID (as query parameter)</param>
        /// <returns>Status 204 if deleted</returns>
        [HttpDelete]
        public async Task<IActionResult> RemoveFavorite([FromQuery] int customerId, [FromQuery] int medicineId)
        {
            await _favoritesService.RemoveFavoriteAsync(customerId, medicineId);
            return NoContent();
        }
    }
}
