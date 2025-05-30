using System.IO;
using System.Threading.Tasks;

namespace MedicalVending.Application.Interfaces
{
    public interface IBlobStorageService
    {
        Task<string> UploadPhotoAsync(string containerName, string fileName, Stream fileStream);
        Task DeletePhotoAsync(string containerName, string fileName);
        Task<string> UpdatePhotoAsync(string containerName, string fileName, Stream fileStream);
        Task<Stream> GetPhotoAsync(string containerName, string fileName);
        Task<bool> PhotoExistsAsync(string containerName, string fileName);
    }
} 