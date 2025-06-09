using System.Text.Json.Serialization;

namespace MedicalVending.Application.DTOs
{
    public class DispenseResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string TransactionId { get; set; } = string.Empty;
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public DispenseStatus Status { get; set; }
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum DispenseStatus
    {
        Pending,
        InProgress,
        Completed,
        Failed,
        OutOfStock,
        DeviceOffline
    }
} 