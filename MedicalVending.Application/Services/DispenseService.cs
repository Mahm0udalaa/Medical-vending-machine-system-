using System;
using System.Threading.Tasks;
using Microsoft.Azure.Devices;
using System.Text.Json;
using MedicalVending.Application.DTOs;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Interfaces;
using Microsoft.Extensions.Logging;
using System.Net.Sockets;
using Microsoft.Azure.Devices.Common.Exceptions;
using System.Threading;
using Microsoft.Azure.Devices.Shared;
using MedicalVending.Domain.Entities;

namespace MedicalVending.Application.Services
{
    public class DispenseService : IDispenseService
    {
        private readonly ServiceClient _iotHubClient;
        private readonly RegistryManager _registryManager;
        private readonly IMachineMedicineRepository _stockRepository;
        private readonly ILogger<DispenseService> _logger;
        private const int MaxRetries = 3;
        private const int RetryDelayMs = 1000; // 1 second

        public DispenseService(
            ServiceClient iotHubClient,
            RegistryManager registryManager,
            IMachineMedicineRepository stockRepository,
            ILogger<DispenseService> logger)
        {
            _iotHubClient = iotHubClient;
            _registryManager = registryManager;
            _stockRepository = stockRepository;
            _logger = logger;
        }

        private async Task<T> RetryWithExponentialBackoff<T>(Func<Task<T>> operation, string operationName, int maxRetries = MaxRetries)
        {
            for (int i = 0; i < maxRetries; i++)
            {
                try
                {
                    return await operation();
                }
                catch (Exception ex) when (IsTransientException(ex))
                {
                    if (i == maxRetries - 1)
                        throw; // If this was our last retry, rethrow the exception

                    var delay = (int)Math.Pow(2, i) * RetryDelayMs; // Exponential backoff
                    _logger.LogWarning("Attempt {Attempt} of {MaxRetries} for {Operation} failed: {Message}. Retrying in {Delay}ms...",
                        i + 1, maxRetries, operationName, ex.Message, delay);
                    
                    await Task.Delay(delay);
                }
            }

            throw new Exception($"Operation {operationName} failed after {maxRetries} attempts");
        }

        private bool IsTransientException(Exception ex)
        {
            return ex switch
            {
                TimeoutException => true,
                SocketException => true,
                IotHubCommunicationException => true,
                ServerErrorException => true,
                // Add more transient exception types as needed
                _ => false
            };
        }

        public async Task<DispenseResponse> DispenseMedicineAsync(DispenseRequest request)
        {
            try
            {
                var transactionId = Guid.NewGuid().ToString();

                if (string.IsNullOrEmpty(request.DeviceId))
                {
                    return new DispenseResponse
                    {
                        Success = false,
                        Message = "Device ID is required",
                        TransactionId = transactionId,
                        Status = DispenseStatus.Failed
                    };
                }

                // Check device connectivity with retry
                try
                {
                    var device = await RetryWithExponentialBackoff<Twin>(
                        async () => await _registryManager.GetTwinAsync(request.DeviceId),
                        "GetDeviceTwin"
                    );

                    if (device == null)
                    {
                        return new DispenseResponse
                        {
                            Success = false,
                            Message = "Device not registered in IoT Hub",
                            TransactionId = transactionId,
                            Status = DispenseStatus.DeviceOffline
                        };
                    }

                    var lastActivity = device.Properties.Reported["lastActivityTime"]?.ToString();
                    if (!string.IsNullOrEmpty(lastActivity))
                    {
                        var lastActivityTime = DateTime.Parse(lastActivity);
                        if (DateTime.UtcNow.Subtract(lastActivityTime).TotalMinutes > 5)
                        {
                            return new DispenseResponse
                            {
                                Success = false,
                                Message = "Device appears to be offline (no activity in last 5 minutes)",
                                TransactionId = transactionId,
                                Status = DispenseStatus.DeviceOffline
                            };
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error checking device status after retries: {Message}", ex.Message);
                    return new DispenseResponse
                    {
                        Success = false,
                        Message = "Could not verify device status after multiple attempts. Please check device connectivity.",
                        TransactionId = transactionId,
                        Status = DispenseStatus.DeviceOffline
                    };
                }

                // Validate stock availability with retry
                var stock = await RetryWithExponentialBackoff<MachineMedicine>(
                    async () => await _stockRepository.GetByIdAsync(int.Parse(request.DeviceId), request.MedicineId),
                    "GetStock"
                );

                if (stock == null)
                {
                    return new DispenseResponse
                    {
                        Success = false,
                        Message = "Medicine not found in stock",
                        TransactionId = transactionId,
                        Status = DispenseStatus.Failed
                    };
                }

                if (stock.Quantity < request.Quantity)
                {
                    return new DispenseResponse
                    {
                        Success = false,
                        Message = $"Insufficient stock. Available: {stock.Quantity}, Requested: {request.Quantity}",
                        TransactionId = transactionId,
                        Status = DispenseStatus.OutOfStock
                    };
                }

                var methodInvocation = new CloudToDeviceMethod("dispenseMedicine")
                {
                    ResponseTimeout = TimeSpan.FromSeconds(30)
                };

                var payload = new
                {
                    slot = stock.Slot,
                    quantity = request.Quantity
                };

                methodInvocation.SetPayloadJson(JsonSerializer.Serialize(payload));

                try
                {
                    // Send command to device with retry
                    var response = await RetryWithExponentialBackoff<CloudToDeviceMethodResult>(
                        () => _iotHubClient.InvokeDeviceMethodAsync(request.DeviceId, methodInvocation),
                        "InvokeDeviceMethod"
                    );

                    if (response.Status == 200)
                    {
                        // Update stock with retry
                        stock.Quantity -= request.Quantity;
                        await RetryWithExponentialBackoff<int>(
                            async () => {
                                await _stockRepository.UpdateAsync(stock);
                                return 1; // Return a dummy value since we just need to await the task
                            },
                            "UpdateStock"
                        );

                        return new DispenseResponse
                        {
                            Success = true,
                            Message = "Medicine dispensing in progress",
                            TransactionId = transactionId,
                            Status = DispenseStatus.InProgress
                        };
                    }
                    else if (response.Status == 404)
                    {
                        return new DispenseResponse
                        {
                            Success = false,
                            Message = "Device not found or not connected to IoT Hub",
                            TransactionId = transactionId,
                            Status = DispenseStatus.DeviceOffline
                        };
                    }
                    else
                    {
                        return new DispenseResponse
                        {
                            Success = false,
                            Message = $"Device responded with error status {response.Status}",
                            TransactionId = transactionId,
                            Status = DispenseStatus.Failed
                        };
                    }
                }
                catch (DeviceNotFoundException)
                {
                    return new DispenseResponse
                    {
                        Success = false,
                        Message = "Device not found in IoT Hub",
                        TransactionId = transactionId,
                        Status = DispenseStatus.DeviceOffline
                    };
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error sending command to device after retries: {Message}", ex.Message);
                    return new DispenseResponse
                    {
                        Success = false,
                        Message = "Failed to send command to device after multiple attempts. Please check device connectivity.",
                        TransactionId = transactionId,
                        Status = DispenseStatus.Failed
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in dispense process: {Message}", ex.Message);
                return new DispenseResponse
                {
                    Success = false,
                    Message = "An unexpected error occurred. Please try again later.",
                    Status = DispenseStatus.Failed
                };
            }
        }
    }
} 