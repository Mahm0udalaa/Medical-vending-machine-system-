using MedicalVending.Application.DTOs;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using Microsoft.Azure.Devices;

namespace MedicalVending.API.Controllers
{
    [ApiController]
    [Route("api/vending")]
    public class VendingController : ControllerBase
    {
        private readonly IDispenseService _dispenseService;
        private readonly ServiceClient _iotHubClient;

        public VendingController(IDispenseService dispenseService, ServiceClient iotHubClient)
        {
            _dispenseService = dispenseService;
            _iotHubClient = iotHubClient;
        }

        /// <summary>
        /// Dispense medicine from the vending machine via Azure IoT Hub.
        /// </summary>
        /// <remarks>
        /// Sample request:
        /// 
        ///     POST /api/vending/dispense
        ///     {
        ///         "deviceId": "esp32-dispenser",
        ///         "medicineId": 123,
        ///         "quantity": 1
        ///     }
        /// 
        /// Sample responses:
        /// 
        ///     Success:
        ///     {
        ///         "success": true,
        ///         "message": "Medicine dispensing in progress",
        ///         "transactionId": "guid-here",
        ///         "status": "InProgress"
        ///     }
        /// 
        ///     Out of Stock:
        ///     {
        ///         "success": false,
        ///         "message": "Insufficient stock",
        ///         "transactionId": "guid-here",
        ///         "status": "OutOfStock"
        ///     }
        /// </remarks>
        /// <param name="request">The dispense request containing device ID, medicine ID, and quantity</param>
        /// <returns>Detailed response with transaction ID and status</returns>
        [HttpPost("dispense")]
        [Authorize(Policy = "AllUsers")] 
        [ProducesResponseType(typeof(DispenseResponse), 200)]
        [ProducesResponseType(typeof(DispenseResponse), 400)]
        [ProducesResponseType(typeof(DispenseResponse), 500)]
        public async Task<ActionResult<DispenseResponse>> Dispense([FromBody] DispenseRequest request)
        {
            var response = await _dispenseService.DispenseMedicineAsync(request);
            
            if (response.Status == DispenseStatus.Failed)
                return StatusCode(500, response);
                
            return Ok(response);
        }

        /// <summary>
        /// Get a SAS token for the ESP32 device to connect to Azure IoT Hub.
        /// </summary>
        [HttpGet("device/token")]
        [AllowAnonymous]
        public IActionResult GetDeviceSasToken()
        {
            // TODO: Move these to configuration for security
            string hostName = "med-vend-hub.azure-devices.net";
            string deviceId = "esp32-dispenser";
            string sharedAccessKey = "+2FTwwF2biKyWVb8t11jff+8xVjqbY9hlN1F7jSOT4E=";
            string resourceUri = $"{hostName}/devices/{deviceId}";

            // ? Calculate expiry in controller
            long expiry = DateTimeOffset.UtcNow.ToUnixTimeSeconds() + (365L * 24 * 60 * 60); // 1 year just for Development porpuse should be 1 hour

            // ? Pass expiry to token generator
            string token = SasTokenGenerator.GenerateSasToken(resourceUri, sharedAccessKey, expiry);

            return Ok(new { token, expiresAt = expiry });
        }

        [HttpPost("test-motor")]
        [AllowAnonymous]
        public async Task<IActionResult> TestMotor([FromQuery] string deviceId, [FromQuery] int slot, [FromQuery] int quantity = 1)
        {
            if (string.IsNullOrEmpty(deviceId) || slot <= 0)
                return BadRequest("deviceId and slot are required");

            var payload = new
            {
                slot = slot,
                quantity = quantity
            };

            var methodInvocation = new CloudToDeviceMethod("dispenseMedicine")
            {
                ResponseTimeout = TimeSpan.FromSeconds(10)
            };
            methodInvocation.SetPayloadJson(System.Text.Json.JsonSerializer.Serialize(payload));

            try
            {
                var response = await _iotHubClient.InvokeDeviceMethodAsync(deviceId, methodInvocation);
                if (response.Status == 200)
                    return Ok(new { success = true, message = "Slot test command sent successfully." });
                else
                    return StatusCode(response.Status, new { success = false, message = "Device responded with error.", status = response.Status });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        private static class SasTokenGenerator
        {
            public static string GenerateSasToken(string resourceUri, string key, long expiry)
            {
                string stringToSign = HttpUtility.UrlEncode(resourceUri) + "\n" + expiry;
                var hmac = new HMACSHA256(Convert.FromBase64String(key));
                var signature = Convert.ToBase64String(hmac.ComputeHash(Encoding.UTF8.GetBytes(stringToSign)));
                var sasToken = $"SharedAccessSignature sr={HttpUtility.UrlEncode(resourceUri)}&sig={HttpUtility.UrlEncode(signature)}&se={expiry}";
                return sasToken;
            }
        }
    }
} 