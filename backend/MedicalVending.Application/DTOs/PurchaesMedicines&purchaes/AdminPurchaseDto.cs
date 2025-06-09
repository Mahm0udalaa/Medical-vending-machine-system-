using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    public record AdminPurchaseDto(
    int PurchaseId,
    DateTime PurchaseDate,
    decimal TotalPrice,
    string MachineLocation,
    int CustomerId,
    string CustomerName,
    IEnumerable<PurchaseMedicineResponse> Items
);
}
