using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MedicalVending.Application.DTOs.PurchaesMedicines_purchaes
{
    public record PurchaseStatsDto(
     decimal TotalRevenue,
     int TotalSales,
     DateTime? FromDate = null,
     DateTime? ToDate = null
    );
}
