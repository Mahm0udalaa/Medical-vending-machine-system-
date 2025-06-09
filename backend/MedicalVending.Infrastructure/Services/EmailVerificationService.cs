using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Infrastructure.DataBase;
using MedicalVending.Domain.Interfaces;

namespace MedicalVending.Infrastructure.Services
{
    public class EmailVerificationService : IEmailVerificationService
    {
        private readonly IEmailSender _emailSender;
        private readonly ApplicationDbContext _context;
        private readonly ICustomerRepository _customerRepository;
        private readonly IAdminRepository _adminRepository;
        private readonly Random _random;

        public EmailVerificationService(
            IEmailSender emailSender,
            ApplicationDbContext context,
            ICustomerRepository customerRepository,
            IAdminRepository adminRepository)
        {
            _emailSender = emailSender;
            _context = context;
            _customerRepository = customerRepository;
            _adminRepository = adminRepository;
            _random = new Random();
        }

        public async Task SendVerificationCodeAsync(string email)
        {
            // Check if user exists (either admin or customer)
            var customer = await _customerRepository.GetByEmailAsync(email);
            var admin = await _adminRepository.GetByEmailAsync(email);
            
            if (customer == null && admin == null)
            {
                throw new InvalidOperationException("User not found");
            }

            string userId = customer != null ? customer.CustomerId.ToString() : admin.AdminId.ToString();
            string userName = customer != null ? customer.CustomerName : admin.AdminName;

            // Generate 6-digit code
            var code = _random.Next(100000, 999999).ToString();
            var expirationTime = DateTime.UtcNow.AddMinutes(10);

            // Upsert verification code
            var existingCode = await _context.EmailVerificationCodes
                .FirstOrDefaultAsync(e => e.UserId == userId);

            if (existingCode != null)
            {
                existingCode.Code = code;
                existingCode.ExpirationTime = expirationTime;
            }
            else
            {
                _context.EmailVerificationCodes.Add(new EmailVerificationCode
                {
                    UserId = userId,
                    Code = code,
                    ExpirationTime = expirationTime
                });
            }

            await _context.SaveChangesAsync();

            // Send email with professional template
            var subject = "Medical Vending - Verify Your Email";
            var body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Email Verification</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333333;
            margin: 0;
            padding: 0;
        }}
        .container {{
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
        }}
        .header {{
            background-color: #4CAF50;
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 5px 5px 0 0;
        }}
        .content {{
            padding: 20px;
            background-color: #f9f9f9;
            border: 1px solid #dddddd;
            border-radius: 0 0 5px 5px;
        }}
        .verification-code {{
            font-size: 32px;
            font-weight: bold;
            text-align: center;
            color: #4CAF50;
            padding: 20px;
            margin: 20px 0;
            background-color: #ffffff;
            border: 2px dashed #4CAF50;
            border-radius: 5px;
        }}
        .footer {{
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: #666666;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Email Verification</h1>
        </div>
        <div class='content'>
            <p>Hello {(string.IsNullOrEmpty(userName) ? "there" : userName)},</p>
            <p>Thank you for using Medical Vending. To verify your email address, please use the following verification code:</p>
            
            <div class='verification-code'>
                {code}
            </div>
            
            <p>This code will expire in 10 minutes for security purposes.</p>
            
            <p><strong>Important:</strong></p>
            <ul>
                <li>If you didn't request this verification, please ignore this email.</li>
                <li>Never share this code with anyone.</li>
                <li>Our team will never ask for this code.</li>
            </ul>
            
            <p>If you have any questions or concerns, please don't hesitate to contact our support team.</p>
        </div>
        <div class='footer'>
            <p>This is an automated message, please do not reply to this email.</p>
            <p>&copy; {DateTime.Now.Year} Medical Vending. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";

            await _emailSender.SendEmailAsync(email, subject, body);
        }

        public async Task<bool> VerifyCodeAsync(string email, string code)
        {
            // Check if user exists (either admin or customer)
            var customer = await _customerRepository.GetByEmailAsync(email);
            var admin = await _adminRepository.GetByEmailAsync(email);
            
            if (customer == null && admin == null)
            {
                return false;
            }

            string userId = customer != null ? customer.CustomerId.ToString() : admin.AdminId.ToString();

            var verificationCode = await _context.EmailVerificationCodes
                .FirstOrDefaultAsync(e => 
                    e.UserId == userId && 
                    e.Code == code && 
                    e.ExpirationTime > DateTime.UtcNow);

            if (verificationCode == null)
            {
                return false;
            }

            // Delete used code
            _context.EmailVerificationCodes.Remove(verificationCode);
            await _context.SaveChangesAsync();

            return true;
        }
    }
} 