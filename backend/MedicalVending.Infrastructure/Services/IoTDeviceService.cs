using Microsoft.Azure.Devices;
using System.Text.Json;
using System.Threading.Tasks;
using System;

namespace MedicalVending.Infrastructure.Services
{
    public class IoTDeviceService : IIoTDeviceService
    {
        private readonly ServiceClient _serviceClient;

        public IoTDeviceService(string iotHubConnectionString)
        {
            _serviceClient = ServiceClient.CreateFromConnectionString(iotHubConnectionString);
        }

        public async Task<bool> DispenseMedicineAsync(string deviceId, string medicine, int quantity)
        {
            var methodInvocation = new CloudToDeviceMethod("dispenseMedicine")
            {
                ResponseTimeout = TimeSpan.FromSeconds(30)
            };

            var payload = new { medicine, quantity };
            methodInvocation.SetPayloadJson(JsonSerializer.Serialize(payload));

            var response = await _serviceClient.InvokeDeviceMethodAsync(deviceId, methodInvocation);
            return response.Status == 200;
        }
    }
} 