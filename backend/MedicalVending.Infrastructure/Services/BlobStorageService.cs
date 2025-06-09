using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using MedicalVending.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using System;
using System.IO;
using System.Threading.Tasks;

namespace MedicalVending.Infrastructure.Services
{
    public class BlobStorageService : IBlobStorageService
    {
        private readonly BlobServiceClient _blobServiceClient;

        public BlobStorageService(IConfiguration configuration)
        {
            string connectionString = configuration["AzureStorage:ConnectionString"]
                ?? throw new InvalidOperationException("Azure Storage connection string is not configured.");
            _blobServiceClient = new BlobServiceClient(connectionString);
        }

        public async Task<string> UploadPhotoAsync(string containerName, string fileName, Stream fileStream)
        {
            if (string.IsNullOrEmpty(fileName))
                throw new ArgumentNullException(nameof(fileName));
            if (fileStream == null)
                throw new ArgumentNullException(nameof(fileStream));

            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);
            var blobClient = containerClient.GetBlobClient(fileName);
            var extension = Path.GetExtension(fileName)?.ToLowerInvariant();
            var contentType = extension switch
            {
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                _ => "application/octet-stream"
            };
            var headers = new BlobHttpHeaders
            {
                ContentType = contentType,
                ContentDisposition = "inline"
            };
            await blobClient.UploadAsync(fileStream, new BlobUploadOptions { HttpHeaders = headers });
            return blobClient.Uri.ToString();
        }

        public async Task DeletePhotoAsync(string containerName, string fileName)
        {
            if (string.IsNullOrEmpty(fileName))
                throw new ArgumentNullException(nameof(fileName));
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(fileName);
            await blobClient.DeleteIfExistsAsync();
        }

        public async Task<string> UpdatePhotoAsync(string containerName, string fileName, Stream fileStream)
        {
            // Reuse upload logic (overwrite existing blob)
            return await UploadPhotoAsync(containerName, fileName, fileStream);
        }

        public async Task<Stream> GetPhotoAsync(string containerName, string fileName)
        {
            if (string.IsNullOrEmpty(fileName))
                throw new ArgumentNullException(nameof(fileName));
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(fileName);
            var response = await blobClient.DownloadAsync();
            return response.Value.Content;
        }

        public async Task<bool> PhotoExistsAsync(string containerName, string fileName)
        {
            if (string.IsNullOrEmpty(fileName))
                throw new ArgumentNullException(nameof(fileName));
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(fileName);
            return await blobClient.ExistsAsync();
        }
    }
}
