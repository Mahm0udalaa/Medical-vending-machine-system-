using AutoMapper;
using MedicalVending.Application.DTOs.Customers;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;

namespace MedicalVending.Application.Services
{
    public class CustomerService : ICustomerService
    {
        private readonly ICustomerRepository _customerRepository;
        private readonly IMapper _mapper;
        private readonly IPasswordHasher<Customer> _passwordHasher;

        public CustomerService(
            ICustomerRepository customerRepository,
            IMapper mapper,
            IPasswordHasher<Customer> passwordHasher)
        {
            _customerRepository = customerRepository;
            _mapper = mapper;
            _passwordHasher = passwordHasher;
        }

        public async Task<IEnumerable<CustomerDto>> GetAllAsync()
        {
            try
            {
            var customers = await _customerRepository.GetPagedAsync(1, int.MaxValue);
            return _mapper.Map<IEnumerable<CustomerDto>>(customers);
            }
            catch (Exception ex)
            {
                throw new Exception("Error retrieving customers", ex);
            }
        }

        public async Task<CustomerDto?> GetByIdAsync(int id)
        {
            try
        {
            var customer = await _customerRepository.GetByIdAsync(id);
            return customer == null ? null : _mapper.Map<CustomerDto>(customer);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving customer with ID {id}", ex);
            }
        }

        public async Task AddAsync(RegisterCustomerDto dto)
        {
            try
        {
            if (await _customerRepository.ExistsByEmailAsync(dto.CustomerEmail))
                throw new ConflictException("Email already registered");

            var customer = _mapper.Map<Customer>(dto);
                
                // Store plain text password from RegisterCustomerDto
                if (!string.IsNullOrEmpty(dto.CustomerPass))
                {
                    customer.PasswordHash = dto.CustomerPass;
                }
                
                // Set the role explicitly
                customer.Role = "Customer";
                
            await _customerRepository.AddAsync(customer);
            }
            catch (ConflictException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new Exception("Error registering customer", ex);
            }
        }

        public async Task UpdateAsync(int id, UpdateCustomerDto dto)
        {
            var customer = await _customerRepository.GetByIdAsync(id);
            if (customer == null)
                throw new NotFoundException(nameof(Customer), id);

            // If password update is requested
            if (!string.IsNullOrEmpty(dto.CustomerPass))
            {
                if (string.IsNullOrEmpty(dto.CurrentPassword))
                    throw new BadRequestException("Current password is required when updating password");

                // Verify current password
                var passwordVerificationResult = _passwordHasher.VerifyHashedPassword(
                    customer,
                    customer.PasswordHash,
                    dto.CurrentPassword);

                if (passwordVerificationResult == PasswordVerificationResult.Failed)
                    throw new BadRequestException("Current password is incorrect");

                // Hash and set new password
                customer.PasswordHash = _passwordHasher.HashPassword(customer, dto.CustomerPass);
            }

            // Update other properties
            _mapper.Map(dto, customer);
            await _customerRepository.UpdateAsync(customer);
        }

        public async Task SetPasswordAsync(int customerId, string password)
        {
            try
            {
                var customer = await _customerRepository.GetByIdAsync(customerId);
                if (customer == null)
                    throw new NotFoundException("Customer not found");

                // Store plain text password
                customer.PasswordHash = password;
            await _customerRepository.UpdateAsync(customer);
            }
            catch (NotFoundException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error setting password for customer with ID {customerId}", ex);
            }
        }

        public async Task DeleteAsync(int id)
        {
            try
            {
            if (!await _customerRepository.ExistsAsync(id))
            {
                throw new NotFoundException(nameof(Customer), id);
            }

            await _customerRepository.DeleteAsync(id);
            }
            catch (NotFoundException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting customer with ID {id}", ex);
            }
        }

        public async Task<int> GetCustomerCountAsync()
        {
            try
            {
                return await _customerRepository.GetTotalCountAsync();
            }
            catch (Exception ex)
            {
                throw new Exception("Error getting customer count", ex);
            }
        }

        public async Task<CustomerDto?> GetCustomerByEmailAsync(string email)
        {
            try
        {
            var customer = await _customerRepository.GetByEmailAsync(email);
            return customer == null ? null : _mapper.Map<CustomerDto>(customer);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving customer with email {email}", ex);
            }
        }
    }
}
