using MedicalVending.Application.DTOs.MachineMediciens;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Net;
using System.Text.Json;
using MedicalVending.Domain.Exceptions;

namespace MedicalVending.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MachineMedicineController : ControllerBase
    {
        private readonly IMachineMedicineService _machineMedicineService;

        public MachineMedicineController(IMachineMedicineService machineMedicineService)
        {
            _machineMedicineService = machineMedicineService;
        }

        /// <summary>
        /// Get all medicines in a specific vending machine.
        /// </summary>
        /// <param name="machineId">The ID of the vending machine</param>
        /// <returns>List of medicines with their stock details in the specified machine</returns>
        [HttpGet("machine/{machineId}")]
        public async Task<ActionResult<IEnumerable<MachineStockDto>>> GetMedicinesInMachine(int machineId)
        {
            var medicines = await _machineMedicineService.GetMedicinesInMachineAsync(machineId);
            if (!medicines.Any())
            {
                return NotFound($"No medicines found in machine with ID {machineId}");
            }
            return Ok(medicines);
        }

        /// <summary>
        /// Get stock details of a specific medicine in a vending machine.
        /// </summary>
        [HttpGet("{machineId}/{medicineId}")]
        [Authorize(Policy = "AllUsers")]
        public async Task<ActionResult<MachineStockDto>> GetStock(int machineId, int medicineId)
        {
            var stock = await _machineMedicineService.GetStockAsync(machineId, medicineId);
            return Ok(stock);
        }

        /// <summary>
        /// Update stock quantity of a medicine in a vending machine.
        /// </summary>
        [HttpPut]
        [Authorize(Policy = "AdminOnly")]
        public async Task<IActionResult> UpdateStock([FromBody] UpdateStockDto dto)
        {
            await _machineMedicineService.UpdateStockAsync(dto);
            return NoContent();
        }

        /// <summary>
        /// Add a new medicine to a vending machine.
        /// </summary>
        /// <param name="dto">The medicine and machine details</param>
        /// <returns>The newly created machine medicine stock entry</returns>
        [HttpPost]
        [Authorize(Policy = "AdminOnly")]
        [ProducesResponseType(typeof(MachineStockDto), (int)HttpStatusCode.Created)]
        [ProducesResponseType((int)HttpStatusCode.BadRequest)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        public async Task<ActionResult<MachineStockDto>> AddMedicineToMachine([FromBody] AddMedicineToMachineDto dto)
        {
            try
            {
                var result = await _machineMedicineService.AddMedicineToMachineAsync(dto);
                return CreatedAtAction(nameof(GetStock), new { machineId = result.MachineId, medicineId = result.MedicineId }, result);
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                try
                {
                    // Try to parse the exception message as JSON
                    var errorDetails = JsonSerializer.Deserialize<object>(ex.Message);
                    return BadRequest(errorDetails);
                }
                catch
                {
                    // If parsing fails, return the message as a simple error
                    return BadRequest(new { error = ex.Message });
                }
            }
        }

        /// <summary>
        /// Get medicines with stock below a specified threshold.
        /// </summary>
        /// <param name="threshold">The maximum quantity threshold. Returns items with stock less than or equal to this value.</param>
        /// <remarks>
        /// Sample request:
        ///     
        ///     GET /api/MachineMedicine/low-stock/10
        ///     
        /// This endpoint will return all medicines in all vending machines that have a quantity of 10 or less in stock.
        /// This is useful for inventory management and determining which items need to be restocked soon.
        /// </remarks>
        /// <response code="200">Returns a list of medicine stock items below the threshold</response>
        /// <response code="404">If no items are found below the threshold</response>
        [HttpGet("low-stock/{threshold}")]
        [Authorize(Policy = "AdminOnly")]
        [ProducesResponseType(typeof(IEnumerable<MachineStockDto>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        public async Task<ActionResult<IEnumerable<MachineStockDto>>> GetLowStockItems(int threshold)
        {
            var items = await _machineMedicineService.GetLowStockItemsAsync(threshold);
            
            if (!items.Any())
            {
                return NotFound($"No items found with stock below or equal to {threshold}");
            }
            
            return Ok(items);
        }

        /// <summary>
        /// Delete a specific medicine from a specific vending machine (does not delete the medicine from the whole system).
        /// </summary>
        [HttpDelete("{machineId}/{medicineId}")]
        [Authorize(Policy = "AdminOnly")]
        public async Task<IActionResult> DeleteMedicineFromMachine(int machineId, int medicineId)
        {
            await _machineMedicineService.DeleteMedicineFromMachineAsync(machineId, medicineId);
            return Ok(new { message = "Medicine removed from machine successfully." });
        }

        /// <summary>
        /// Get all machines (id and location) that have a given medicineId.
        /// </summary>
        /// <param name="medicineId">The ID of the medicine</param>
        /// <returns>List of machines with their location details</returns>
        [HttpGet("machines-by-medicine/{medicineId}")]
        public async Task<ActionResult<IEnumerable<MachineWithLocationDto>>> GetMachinesByMedicine(int medicineId)
        {
            var machines = await _machineMedicineService.GetMachinesByMedicineIdAsync(medicineId);
            return Ok(machines);
        }
    }
}
