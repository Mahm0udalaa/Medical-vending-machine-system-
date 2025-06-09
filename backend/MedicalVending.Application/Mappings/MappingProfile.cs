using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using MedicalVending.Application.DTOs;
using MedicalVending.Application.DTOs.Admins;
using MedicalVending.Application.DTOs.Auth;
using MedicalVending.Application.DTOs.Categorys;
using MedicalVending.Application.DTOs.Customers;
using MedicalVending.Application.DTOs.FavoritesMedicines;
using MedicalVending.Application.DTOs.MachineMediciens;
using MedicalVending.Application.DTOs.Medicines;
using MedicalVending.Application.DTOs.PurchaesMedicines_purchaes;
using MedicalVending.Application.DTOs.VendingMachiens;
using MedicalVending.Domain.Entities;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace MedicalVending.Application.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            // Admin mappings
            CreateMap<Admin, AdminDto>();
            CreateMap<CreateAdminDto, Admin>();
            CreateMap<UpdateAdminDto, Admin>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            // Customer mappings
            CreateMap<Customer, CustomerDto>();
            CreateMap<RegisterCustomerDto, Customer>()
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore());
            CreateMap<UpdateCustomerDto, Customer>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            // Category mappings
            CreateMap<Category, CategoryDto>()
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.ImagePath));
            CreateMap<CreateCategoryDto, Category>();
            CreateMap<UpdateCategoryDto, Category>()
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.ImagePath))
           .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            // Medicine mappings
            CreateMap<Medicine, MedicineDto>()
                .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.CategoryName));
            CreateMap<CreateMedicineDto, Medicine>()
                .ForMember(dest => dest.ImagePath, opt => opt.Ignore());  // Ignore, handled in service
            CreateMap<UpdateMedicineDto, Medicine>()
                .ForMember(dest => dest.ImagePath, opt => opt.Ignore())  // Ignore, handled in service
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            
            // Simple Medicine DTO
            CreateMap<Medicine, MedicineSimpleDto>()
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.ImagePath));

            // VendingMachine mappings
            CreateMap<VendingMachine, MachineDto>()
                .ForMember(dest => dest.AdminName, opt => opt.MapFrom(src => src.Admin.AdminName))
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.ImagePath));
            CreateMap<CreateMachineDto, VendingMachine>();
            CreateMap<UpdateMachineDto, VendingMachine>()
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.ImagePath))
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            // MachineMedicine mappings
            CreateMap<MachineMedicine, MachineStockDto>()
                .ForMember(dest => dest.MachineLocation, opt => opt.MapFrom(src => src.VendingMachine.Location))
                .ForMember(dest => dest.MedicineName, opt => opt.MapFrom(src => src.Medicine.MedicineName))
                .ForMember(dest => dest.MedicinePrice, opt => opt.MapFrom(src => src.Medicine.MedicinePrice))
                .ForMember(dest => dest.MedicineId, opt => opt.MapFrom(src => src.MedicineId))
                .ForMember(dest => dest.CategoryId, opt => opt.MapFrom(src => src.Medicine.CategoryId))
                .ForMember(dest => dest.Description, opt => opt.MapFrom(src => src.Medicine.Description))
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.Medicine.ImagePath))
                .ForMember(dest => dest.Slot, opt => opt.MapFrom(src => src.Slot));

            CreateMap<UpdateStockDto, MachineMedicine>()
                .ForMember(dest => dest.Quantity, opt => opt.MapFrom(src => src.Quantity));

            // Purchase mappings
            CreateMap<Purchase, PurchaseDto>()
                .ForMember(dest => dest.PurchaseId, opt => opt.MapFrom(src => src.PurchaseId))
                .ForMember(dest => dest.PurchaseDate, opt => opt.MapFrom(src => src.PurchaseDate))
                .ForMember(dest => dest.MachineId, opt => opt.MapFrom(src => src.MachineId))
                .ForMember(dest => dest.TotalPrice, opt => opt.MapFrom(src => src.TotalPrice))
                .ForMember(dest => dest.Items, opt => opt.MapFrom(src => src.PurchaseMedicines));

            CreateMap<PurchaseMedicine, PurchaseMedicineResponse>()
                .ForMember(dest => dest.MedicineName, opt => opt.MapFrom(src => src.Medicine != null ? 
                    src.Medicine.MedicineName ?? "Unknown Medicine" : "Unknown Medicine"))
                .ForMember(dest => dest.PricePerUnit, opt => opt.MapFrom(src => src.PricePerUnit))
                .ForMember(dest => dest.TotalPriceUnit, opt => opt.MapFrom(src => src.TotalPriceUnit))
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.Medicine != null ? src.Medicine.ImagePath : null));

            CreateMap<CreatePurchaseDto, Purchase>()
            .ForMember(dest => dest.PurchaseDate, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.PurchaseMedicines, opt => opt.Ignore());

            CreateMap<CreatePurchaseMedicineRequest, PurchaseMedicine>()
                .ForMember(dest => dest.TotalPriceUnit,
                    opt => opt.MapFrom(src => src.Quantity * src.PricePerUnit))
                .ForMember(dest => dest.Purchase, opt => opt.Ignore())
                .ForMember(dest => dest.Medicine, opt => opt.Ignore());

            // Admin Purchase Mapping
            CreateMap<Purchase, AdminPurchaseDto>()
                .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => src.Customer.CustomerName))
                .ForMember(dest => dest.MachineLocation, opt => opt.MapFrom(src => src.VendingMachine.Location))
     .ForMember(dest => dest.Items, opt => opt.MapFrom(src => src.PurchaseMedicines));

            // FavoritesMedicine mappings
            CreateMap<FavoritesMedicine, FavoriteDto>()
                .ForMember(dest => dest.MedicineName, opt => opt.MapFrom(src => src.Medicine.MedicineName))
                .ForMember(dest => dest.MedicinePrice, opt => opt.MapFrom(src => src.Medicine.MedicinePrice))
                .ForMember(dest => dest.ImagePath, opt => opt.MapFrom(src => src.Medicine.ImagePath));

            CreateMap<AddFavoriteDto, FavoritesMedicine>();
        }
    }
}
