using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Services
{
    public interface IIoTDeviceService
    {
        Task<bool> DispenseMedicineAsync(string deviceId, string medicine, int quantity);
    }
} 