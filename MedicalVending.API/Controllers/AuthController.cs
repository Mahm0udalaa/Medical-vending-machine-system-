using MedicalVending.Application.DTOs;
using MedicalVending.Application.DTOs.Auth;
using MedicalVending.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.ResponseCaching;
using System.ComponentModel.DataAnnotations;
using MedicalVending.API.Models;

namespace MedicalVending.API.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IEmailVerificationService _emailVerificationService;

        public AuthController(
            IAuthService authService,
            IEmailVerificationService emailVerificationService)
        {
            _authService = authService;
            _emailVerificationService = emailVerificationService;
        }

        /// <summary>
        /// Register a new user (admin or customer)
        /// </summary>
        /// <param name="model">Registration details including email, password, and role</param>
        /// <returns>Success message if registration is successful</returns>
        /// <response code="200">Registration successful</response>
        /// <response code="400">Invalid input data</response>
        /// <response code="429">Too many requests</response>
        [HttpPost("register")]
        [EnableRateLimiting("register")]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status429TooManyRequests)]
        public async Task<IActionResult> Register([FromBody] RegisterRequestDto model)
        {
            var result = await _authService.Register(model);
            return Ok(new ApiResponse { Message = result, Success = true });
        }

        /// <summary>
        /// Login a user and get user details
        /// </summary>
        /// <param name="model">Login credentials</param>
        /// <returns>JWT token and user details</returns>
        /// <response code="200">Login successful</response>
        /// <response code="400">Invalid credentials</response>
        /// <response code="429">Too many requests</response>
        [HttpPost("login")]
        [EnableRateLimiting("login")]
        [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status429TooManyRequests)]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto model)
        {
            var response = await _authService.Login(model);
            return Ok(response);
        }

        /// <summary>
        /// Refresh the access token using a refresh token
        /// </summary>
        /// <param name="request">The refresh token request object</param>
        /// <returns>New access and refresh tokens</returns>
        /// <response code="200">Token refresh successful</response>
        /// <response code="400">Invalid refresh token</response>
        [HttpPost("refresh-token")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            var response = await _authService.RefreshToken(request.RefreshToken);
            return Ok(response);
        }

        /// <summary>
        /// Revoke (logout) a refresh token.
        /// </summary>
        /// <param name="request">The refresh token request object.</param>
        /// <returns>Status message.</returns>
        [HttpPost("logout")]
        [AllowAnonymous]
        public async Task<IActionResult> Logout([FromBody] RefreshTokenRequest request)
        {
            await _authService.Logout(request.RefreshToken);
            return Ok(new { message = "Logged out successfully." });
        }

        /// <summary>
        /// Send email verification code
        /// </summary>
        /// <param name="request">Email address to send verification code to</param>
        /// <returns>Success message</returns>
        /// <response code="200">Verification code sent successfully</response>
        /// <response code="400">Invalid email address</response>
        /// <response code="429">Too many requests</response>
        [HttpPost("send-code")]
        [AllowAnonymous]
        [EnableRateLimiting("login")]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status429TooManyRequests)]
        public async Task<IActionResult> SendVerificationCode([FromBody] SendCodeRequest request)
        {
            try
            {
                await _emailVerificationService.SendVerificationCodeAsync(request.Email);
                return Ok(new ApiResponse { Message = "Verification code sent successfully.", Success = true });
            }
            catch (Exception ex)
            {
                return BadRequest(new ApiResponse { Message = ex.Message, Success = false });
            }
        }

        /// <summary>
        /// Verify email with code
        /// </summary>
        [HttpPost("verify-code")]
        [AllowAnonymous]
        public async Task<IActionResult> VerifyCode([FromBody] VerifyCodeRequest request)
        {
            var result = await _emailVerificationService.VerifyCodeAsync(request.Email, request.Code);
            if (result)
            {
                return Ok(new { message = "Email verified successfully." });
            }
            return BadRequest(new { message = "Invalid or expired verification code." });
        }

        /// <summary>
        /// Verify password reset code without changing the password
        /// </summary>
        [HttpPost("verify-reset-code")]
        [AllowAnonymous]
        public async Task<IActionResult> VerifyResetCode([FromBody] VerifyResetCodeRequest request)
        {
            try
            {
                var isValid = await _authService.VerifyPasswordResetCode(request.Email, request.Code);
                
                if (isValid)
                {
                    return Ok(new { 
                        statusCode = 200, 
                        success = true, 
                        message = "Code is valid",
                        data = new { isValid = true }
                    });
                }
                else
                {
                    return BadRequest(new { 
                        statusCode = 400, 
                        success = false, 
                        message = "Invalid or expired verification code",
                        data = new { isValid = false }
                    });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new {
                    statusCode = 500,
                    success = false,
                    message = "An error occurred while verifying the code",
                    error = ex.Message
                });
            }
        }

        /// <summary>
        /// Request a password reset by sending a 6-digit code to the user's email
        /// </summary>
        [HttpPost("forgot-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            try
            {
                var result = await _authService.RequestPasswordReset(request.Email);
                if (!result)
                {
                    return NotFound(new {
                        statusCode = 404,
                        success = false,
                        message = "Email does not exist in our system.",
                        data = new { }
                    });
                }
                return Ok(new {
                    statusCode = 200,
                    success = true,
                    message = "A password reset code has been sent to your email.",
                    data = new { }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new {
                    statusCode = 500,
                    success = false,
                    message = "An error occurred while processing the request",
                    error = ex.Message
                });
            }
        }

        /// <summary>
        /// Reset the password using the 6-digit code sent to the user's email
        /// </summary>
        [HttpPost("reset-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            try
            {
                var result = await _authService.ResetPassword(request.Email, request.Code, request.NewPassword);
                
                if (result)
                {
                    return Ok(new { 
                        statusCode = 200, 
                        success = true, 
                        message = "Password reset successfully",
                        data = new { }
                    });
                }
                else
                {
                    return BadRequest(new { 
                        statusCode = 400, 
                        success = false, 
                        message = "Invalid or expired verification code",
                        data = new { }
                    });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new {
                    statusCode = 500,
                    success = false,
                    message = "An error occurred while resetting the password",
                    error = ex.Message
                });
            }
        }
    }
}
