namespace MedicalVending.Application.DTOs.Auth
{
    public class LoginResponse
    {
        public int Id { get; set; }
        public string Role { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public DateTime TokenExpiresAt { get; set; }
        public DateTime RefreshTokenExpiresAt { get; set; }
    }
} 