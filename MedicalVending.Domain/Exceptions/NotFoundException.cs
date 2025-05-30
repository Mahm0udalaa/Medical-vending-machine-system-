using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace MedicalVending.Domain.Exceptions
{
    public class NotFoundException : Exception
    {
        public NotFoundException() { }
        public NotFoundException(string message) : base(message) { }

        // Constructor with message and inner exception
        public NotFoundException(string message, Exception inner) : base(message, inner) { }

       
        public NotFoundException(string entityName, object key)
            : base($"Entity \"{entityName}\" with key ({key}) was not found.")
        {
            EntityName = entityName;
            Key = key;
        }
        public string? EntityName { get; }
        public object? Key { get; }
    }
}
