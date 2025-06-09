using System;
using System.Net.Mail;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using MedicalVending.Application.Interfaces;
using System.Net;

namespace MedicalVending.Infrastructure.Services
{
    public class SmtpEmailSender : IEmailSender
    {
        private readonly IConfiguration _configuration;
        private readonly string _host;
        private readonly int _port;
        private readonly string _email;
        private readonly string _password;

        public SmtpEmailSender(IConfiguration configuration)
        {
            _configuration = configuration;
            _host = _configuration["Smtp:Host"] ?? throw new ArgumentNullException("Smtp:Host");
            _port = int.Parse(_configuration["Smtp:Port"] ?? "587");
            _email = _configuration["Smtp:Email"] ?? throw new ArgumentNullException("Smtp:Email");
            _password = _configuration["Smtp:Password"] ?? throw new ArgumentNullException("Smtp:Password");
        }

        public async Task SendEmailAsync(string to, string subject, string body)
        {
            var smtpClient = new SmtpClient(_host)
            {
                Port = _port,
                Credentials = new NetworkCredential(_email, _password),
                EnableSsl = true,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false
            };

            using var message = new MailMessage
            {
                From = new MailAddress(_email),
                Subject = subject,
                Body = body,
                IsBodyHtml = true
            };
            message.To.Add(to);

            try 
            {
                await smtpClient.SendMailAsync(message);
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to send email. Error: {ex.Message}", ex);
            }
        }
    }
} 