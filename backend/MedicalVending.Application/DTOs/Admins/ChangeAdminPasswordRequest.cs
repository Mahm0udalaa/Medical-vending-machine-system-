namespace MedicalVending.Application.DTOs.Admins
{
    public class ChangeAdminPasswordRequest
    {
        public string CurrentPassword { get; set; }
        public string NewPassword { get; set; }
    }
} 