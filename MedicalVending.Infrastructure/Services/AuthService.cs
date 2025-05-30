using System;
using System.Threading.Tasks;
using MedicalVending.Application.DTOs;
using MedicalVending.Application.DTOs.Auth;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using BCrypt.Net;
using MedicalVending.Domain.Interfaces;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Security.Cryptography;

namespace MedicalVending.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<AuthService> _logger;
        private readonly ICustomerRepository _customerRepository;
        private readonly IAdminRepository _adminRepository;
        private readonly IConfiguration _configuration;

        public AuthService(
            ApplicationDbContext context,
            ILogger<AuthService> logger,
            ICustomerRepository customerRepository,
            IAdminRepository adminRepository,
            IConfiguration configuration)
        {
            _context = context;
            _logger = logger;
            _customerRepository = customerRepository;
            _adminRepository = adminRepository;
            _configuration = configuration;
        }

        public async Task<LoginResponse> Login(LoginRequestDto model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            if (string.IsNullOrWhiteSpace(model.Email))
                throw new ArgumentException("Email cannot be empty or whitespace", nameof(model));

            if (string.IsNullOrWhiteSpace(model.Password))
                throw new ArgumentException("Password cannot be empty or whitespace", nameof(model));

            try
            {
                // Check for admin
                var admin = await _context.Admins.FirstOrDefaultAsync(a => a.AdminEmail == model.Email);
                if (admin != null && admin.PasswordHash != null && VerifyPassword(model.Password, admin.PasswordHash))
                {
                    var (accessToken, refreshToken, tokenExpiresAt, refreshTokenExpiresAt) = 
                        await GenerateTokens(admin.AdminId, "Admin", admin.AdminEmail);
                    
                    return new LoginResponse
                    {
                        Id = admin.AdminId,
                        Role = "Admin",
                        Token = accessToken,
                        RefreshToken = refreshToken,
                        TokenExpiresAt = tokenExpiresAt,
                        RefreshTokenExpiresAt = refreshTokenExpiresAt
                    };
                }

                // Check for customer
                var customer = await _context.Customers.FirstOrDefaultAsync(c => c.CustomerEmail == model.Email);
                if (customer != null && customer.PasswordHash != null && VerifyPassword(model.Password, customer.PasswordHash))
                {
                    var (accessToken, refreshToken, tokenExpiresAt, refreshTokenExpiresAt) = 
                        await GenerateTokens(customer.CustomerId, "Customer", customer.CustomerEmail);
                    
                    return new LoginResponse
                    {
                        Id = customer.CustomerId,
                        Role = "Customer",
                        Token = accessToken,
                        RefreshToken = refreshToken,
                        TokenExpiresAt = tokenExpiresAt,
                        RefreshTokenExpiresAt = refreshTokenExpiresAt
                    };
                }

                throw new UnauthorizedAccessException("Invalid credentials");
            }
            catch (Exception ex) when (ex is not UnauthorizedAccessException)
            {
                _logger.LogError(ex, "Error during login attempt for email {Email}", model.Email);
                throw;
            }
        }

        public async Task<LoginResponse> RefreshToken(string refreshToken)
        {
            if (string.IsNullOrEmpty(refreshToken))
                throw new ArgumentNullException(nameof(refreshToken));

            var token = await _context.RefreshTokens
                .Include(r => r.Admin)
                .Include(r => r.Customer)
                .FirstOrDefaultAsync(r => r.Token == refreshToken);

            if (token == null || token.IsRevoked || token.IsUsed || token.ExpiresAt < DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Invalid refresh token");
            }

            // Mark the refresh token as used
            token.IsUsed = true;
            await _context.SaveChangesAsync();

            int userId;
            string role;
            string email;

            if (token.AdminId.HasValue)
            {
                userId = token.AdminId.Value;
                role = "Admin";
                email = token.Admin?.AdminEmail ?? throw new InvalidOperationException("Admin not found");
            }
            else if (token.CustomerId.HasValue)
            {
                userId = token.CustomerId.Value;
                role = "Customer";
                email = token.Customer?.CustomerEmail ?? throw new InvalidOperationException("Customer not found");
            }
            else
            {
                throw new InvalidOperationException("Invalid token configuration");
            }

            var (accessToken, newRefreshToken, tokenExpiresAt, refreshTokenExpiresAt) = await GenerateTokens(userId, role, email);

            return new LoginResponse
            {
                Id = userId,
                Role = role,
                Token = accessToken,
                RefreshToken = newRefreshToken,
                TokenExpiresAt = tokenExpiresAt,
                RefreshTokenExpiresAt = refreshTokenExpiresAt
            };
        }

        private async Task<(string accessToken, string refreshToken, DateTime tokenExpiresAt, DateTime refreshTokenExpiresAt)> GenerateTokens(int userId, string role, string email)
        {
            // Validate inputs
            if (userId <= 0)
                throw new ArgumentException("Invalid user ID", nameof(userId));
                
            if (string.IsNullOrWhiteSpace(role))
                throw new ArgumentException("Role cannot be empty or whitespace", nameof(role));
                
            if (!new[] { "Admin", "Customer" }.Contains(role))
                throw new ArgumentException("Invalid role. Must be either 'Admin' or 'Customer'", nameof(role));
                
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("Email cannot be empty or whitespace", nameof(email));
                
            if (!email.Contains("@") || !email.Contains("."))
                throw new ArgumentException("Invalid email format", nameof(email));

            try
            {
                var jwtSettings = _configuration.GetSection("Jwt");
                var keyString = jwtSettings["Key"] ?? throw new InvalidOperationException("JWT Key is not configured in appsettings.json");
                var issuer = jwtSettings["Issuer"] ?? throw new InvalidOperationException("JWT Issuer is not configured");
                var audience = jwtSettings["Audience"] ?? throw new InvalidOperationException("JWT Audience is not configured");

                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));
                var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
                
                var tokenExpiresAt = DateTime.UtcNow.AddHours(5); // Access token expires in 5 hours
                var refreshTokenExpiresAt = DateTime.UtcNow.AddDays(30); // Refresh token expires in 7 days

                var claims = new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
                    new Claim(ClaimTypes.Role, role),
                    new Claim(ClaimTypes.Email, email)
                };

                var token = new JwtSecurityToken(
                    issuer: issuer,
                    audience: audience,
                    claims: claims,
                    expires: tokenExpiresAt,
                    signingCredentials: creds
                );

                var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
                var refreshToken = GenerateRefreshToken();

                // Save refresh token to database
                var refreshTokenEntity = new RefreshToken
                {
                    Token = refreshToken,
                    ExpiresAt = refreshTokenExpiresAt,
                    CreatedAt = DateTime.UtcNow,
                    IsRevoked = false,
                    IsUsed = false
                };

                switch (role)
                {
                    case "Admin":
                        refreshTokenEntity.AdminId = userId;
                        break;
                    case "Customer":
                        refreshTokenEntity.CustomerId = userId;
                        break;
                    default:
                        throw new ArgumentException("Invalid role specified", nameof(role));
                }

                _context.RefreshTokens.Add(refreshTokenEntity);
                await _context.SaveChangesAsync();

                return (accessToken, refreshToken, tokenExpiresAt, refreshTokenExpiresAt);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating tokens for user {UserId} with role {Role}", userId, role);
                throw;
            }
        }

        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }

        public async Task<string> Register(RegisterRequestDto model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));
                
            if (string.IsNullOrEmpty(model.Email))
                throw new ArgumentException("Email is required", nameof(model));
                
            if (string.IsNullOrEmpty(model.Password))
                throw new ArgumentException("Password is required", nameof(model));
                
            if (string.IsNullOrEmpty(model.Username))
                throw new ArgumentException("Username is required", nameof(model));

            // Validate role
            if (model.Role != "Admin" && model.Role != "Customer")
                throw new ArgumentException("Invalid role specified. Role must be either 'Admin' or 'Customer'");

            if (model.Role == "Admin")
            {
                if (await _context.Admins.AnyAsync(a => a.AdminEmail == model.Email))
                    throw new ConflictException("Admin already exists");

                var admin = new Admin
                {
                    AdminEmail = model.Email,
                    AdminName = model.Username,
                    Role = "Admin",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(model.Password)
                };

                _context.Admins.Add(admin);
            }
            else
            {
                if (await _context.Customers.AnyAsync(c => c.CustomerEmail == model.Email))
                    throw new ConflictException("Customer already exists");

                var customer = new Customer
                {
                    CustomerEmail = model.Email,
                    CustomerName = model.Username,
                    CustomerPhone = model.Phone,
                    Role = "Customer",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(model.Password),
                    Age = model.Age
                };

                _context.Customers.Add(customer);
            }

            await _context.SaveChangesAsync();
            return "User registered successfully";
        }

        public async Task<Customer?> ValidateUserAsync(string email, string password)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                return null;
            }

            var customer = await _customerRepository.GetByEmailAsync(email);
            if (customer?.PasswordHash != null && VerifyPassword(password, customer.PasswordHash))
            {
                return customer;
            }

            var admin = await _adminRepository.GetByEmailAsync(email);
            if (admin?.PasswordHash != null && VerifyPassword(password, admin.PasswordHash))
            {
                return new Customer 
                { 
                    CustomerId = admin.AdminId,
                    CustomerEmail = admin.AdminEmail,
                    CustomerName = admin.AdminName,
                    Role = "Admin"
                };
            }

            return null;
        }

        public async Task<Customer?> GetCustomerByEmailAsync(string email)
        {
            return await _customerRepository.GetByEmailAsync(email);
        }

        public async Task<Admin?> GetAdminByEmailAsync(string email)
        {
            return await _adminRepository.GetByEmailAsync(email);
        }

        private bool VerifyPassword(string password, string passwordHash)
        {
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(passwordHash))
            {
                return false;
            }
            return BCrypt.Net.BCrypt.Verify(password, passwordHash);
        }

        public async Task Logout(string refreshToken)
        {
            var token = await _context.RefreshTokens.FirstOrDefaultAsync(r => r.Token == refreshToken);
            if (token != null && !token.IsRevoked)
            {
                token.IsRevoked = true;
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> RequestPasswordReset(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("Email cannot be empty or whitespace", nameof(email));

            try
            {
                // Check if user exists (either admin or customer)
                var customer = await _customerRepository.GetByEmailAsync(email);
                var admin = await _adminRepository.GetByEmailAsync(email);
                
                if (customer == null && admin == null)
                {
                    return false;
                }

                string userId = customer != null ? customer.CustomerId.ToString() : admin.AdminId.ToString();
                string userName = customer != null ? customer.CustomerName : admin.AdminName;

                // Generate 6-digit code
                var random = new Random();
                var code = random.Next(100000, 999999).ToString();
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

                // Send email with professional password reset template
                var emailSender = new SmtpEmailSender(_configuration);
                var subject = "Medical Vending - Password Reset";
                var body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Password Reset</title>
    <style>
        body {{
            font-family: 'Segoe UI', Arial, sans-serif;
            line-height: 1.6;
            color: #333333;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
        }}
        .container {{
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }}
        .header {{
            background-color: #4a6da7;
            color: white;
            padding: 25px;
            text-align: center;
            border-radius: 8px 8px 0 0;
        }}
        .content {{
            padding: 30px;
            background-color: #ffffff;
            border: 1px solid #dddddd;
            border-top: none;
            border-radius: 0 0 8px 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }}
        .verification-code {{
            font-size: 36px;
            font-weight: bold;
            text-align: center;
            letter-spacing: 4px;
            color: #4a6da7;
            padding: 20px;
            margin: 25px 0;
            background-color: #f0f5ff;
            border: 2px dashed #4a6da7;
            border-radius: 8px;
        }}
        .instructions {{
            margin-bottom: 25px;
            color: #555555;
        }}
        .footer {{
            text-align: center;
            margin-top: 30px;
            font-size: 12px;
            color: #888888;
            padding-top: 20px;
            border-top: 1px solid #eeeeee;
        }}
        .note {{
            background-color: #fff8e1;
            padding: 12px;
            border-left: 4px solid #ffc107;
            margin: 20px 0;
            border-radius: 4px;
        }}
        .help {{
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #666666;
        }}
        .logo {{
            font-size: 24px;
            font-weight: bold;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <div class='logo'>Medical Vending</div>
            <h1>Password Reset</h1>
        </div>
        <div class='content'>
            <p>Hello {(string.IsNullOrEmpty(userName) ? "there" : userName)},</p>
            
            <div class='instructions'>
                <p>We received a request to reset your password for your Medical Vending account. To complete the process, please use the verification code below:</p>
            </div>
            
            <div class='verification-code'>
                {code}
            </div>
            
            <p>This code will expire in 10 minutes for security purposes.</p>
            
            <div class='note'>
                <strong>⚠️ Security Notice:</strong>
                <ul>
                    <li>If you didn't request this password reset, please ignore this email or contact support immediately.</li>
                    <li>Never share this code with anyone.</li>
                    <li>Our staff will never ask you for this code.</li>
                </ul>
            </div>
            
            <div class='help'>
                <p>Need assistance? Contact our support team at <a href='mailto:support@medicalvending.com'>support@medicalvending.com</a></p>
            </div>
        </div>
        <div class='footer'>
            <p>This is an automated message, please do not reply to this email.</p>
            <p>&copy; {DateTime.Now.Year} Medical Vending. All rights reserved.</p>
            <p>Medical Vending Inc, 123 Health Avenue, Medicity, MC 12345</p>
        </div>
    </div>
</body>
</html>";

                await emailSender.SendEmailAsync(email, subject, body);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during password reset request for email {Email}", email);
                throw;
            }
        }

        public async Task<bool> ResetPassword(string email, string code, string newPassword)
        {
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("Email cannot be empty or whitespace", nameof(email));
                
            if (string.IsNullOrWhiteSpace(code))
                throw new ArgumentException("Verification code cannot be empty or whitespace", nameof(code));
                
            if (string.IsNullOrWhiteSpace(newPassword))
                throw new ArgumentException("New password cannot be empty or whitespace", nameof(newPassword));

            try
            {
                // Verify the code
                var emailVerificationService = new EmailVerificationService(
                    new SmtpEmailSender(_configuration),
                    _context,
                    _customerRepository,
                    _adminRepository);
                    
                var isCodeValid = await emailVerificationService.VerifyCodeAsync(email, code);
                if (!isCodeValid)
                {
                    return false;
                }

                // Update the password
                var customer = await _customerRepository.GetByEmailAsync(email);
                if (customer != null)
                {
                    customer.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
                    await _customerRepository.UpdateAsync(customer);
                    return true;
                }

                var admin = await _adminRepository.GetByEmailAsync(email);
                if (admin != null)
                {
                    admin.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
                    await _adminRepository.UpdateAsync(admin);
                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during password reset for email {Email}", email);
                throw;
            }
        }

        public async Task<bool> VerifyPasswordResetCode(string email, string code)
        {
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("Email cannot be empty or whitespace", nameof(email));

            if (string.IsNullOrWhiteSpace(code))
                throw new ArgumentException("Verification code cannot be empty or whitespace", nameof(code));

            try
            {
                // Check if user exists (either admin or customer)
                var customer = await _customerRepository.GetByEmailAsync(email);
                var admin = await _adminRepository.GetByEmailAsync(email);
                
                if (customer == null && admin == null)
                {
                    return false;
                }

                string userId = customer != null ? customer.CustomerId.ToString() : admin.AdminId.ToString();

                // Check if code is valid and not expired
                var verificationCode = await _context.EmailVerificationCodes
                    .FirstOrDefaultAsync(e => 
                        e.UserId == userId && 
                        e.Code == code && 
                        e.ExpirationTime > DateTime.UtcNow);

                return verificationCode != null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying password reset code for email {Email}", email);
                throw;
            }
        }
    }
} 