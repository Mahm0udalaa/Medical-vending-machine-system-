using AutoMapper;
using MedicalVending.Application.DTOs.Admins;
using MedicalVending.Application.Interfaces;
using MedicalVending.Domain.Entities;
using MedicalVending.Domain.Exceptions;
using MedicalVending.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;
using MedicalVending.Application.DTOs;

namespace MedicalVending.Application.Services
{
    public class AdminService : IAdminService
    {
        private readonly IAdminRepository _adminRepository;
        private readonly IMapper _mapper;

        public AdminService(
            IAdminRepository adminRepository,
            IMapper mapper)
        {
            _adminRepository = adminRepository;
            _mapper = mapper;
        }

        public async Task<IEnumerable<AdminDto>> GetAllAsync()
        {
            var admins = await _adminRepository.GetAllAsync();
            return _mapper.Map<IEnumerable<AdminDto>>(admins);
        }

        public async Task<AdminDto?> GetByIdAsync(int id)
        {
            var admin = await _adminRepository.GetByIdAsync(id);
            return admin == null ? null : _mapper.Map<AdminDto>(admin);
        }

        public async Task AddAsync(CreateAdminDto dto)
        {
            var admin = _mapper.Map<Admin>(dto);
            admin.PasswordHash = dto.AdminPass;
            admin.Role = "Admin"; // Set role explicitly
            await _adminRepository.AddAsync(admin);
        }

        public async Task UpdateAsync(int id, UpdateAdminDto dto)
        {
            var admin = await _adminRepository.GetByIdAsync(id)
                ?? throw new NotFoundException("Admin not found");

            _mapper.Map(dto, admin);
            // Ensure role remains unchanged
            admin.Role = "Admin";
            await _adminRepository.UpdateAsync(admin);
        }

        public async Task DeleteAsync(int id)
        {
            if (!await _adminRepository.ExistsAsync(id))
                throw new NotFoundException("Admin not found");

            await _adminRepository.DeleteAsync(id);
        }
    }
}
