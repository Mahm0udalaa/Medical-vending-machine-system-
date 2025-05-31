# Medical Vending Backend

A robust backend API for managing medical vending machines, supporting user authentication, cart management, purchase history, and more. Built with .NET and SQL Server, this project is designed for scalability and security.

## Features
- User registration and JWT-based authentication
- Role-based access (Admin & Customer)
- Cart management (add, update, delete items)
- Purchase and order history
- Medicine and vending machine management
- SQL Server database integration
- Email verification and password reset
- API documentation with Swagger

## Technologies Used
- .NET 7
- Entity Framework Core
- SQL Server
- Azure (optional for IoT and storage)
- JWT Authentication
- Swagger (OpenAPI)

## Getting Started

### Prerequisites
- [.NET 7 SDK](https://dotnet.microsoft.com/download)
- SQL Server (local or cloud)

### Installation
```bash
git clone https://github.com/Mahm0udalaa/medical-vending-backend.git
cd medical-vending-backend
```

### Configuration
- Update `appsettings.json` in `MedicalVending.API` with your:
  - `ConnectionStrings:DefaultConnection`
  - `Jwt:Key`, `Jwt:Issuer`, `Jwt:Audience`
  - `Smtp` settings for email
  - `AzureIoTHub` and `AzureStorage` if using Azure features

### Database Setup
- Run the provided SQL scripts in your SQL Server to create necessary tables.
- Or, use Entity Framework migrations:
```bash
dotnet ef database update --project MedicalVending.Infrastructure
```

### Running the API
```bash
dotnet run --project MedicalVending.API
```
- The API will be available at `http://localhost:5000` (or your configured port).
- Visit `/swagger` for interactive API documentation.

## API Reference

### Main Endpoints
- `POST /api/Auth/login` — User login
- `POST /api/Auth/register` — User registration
- `GET /api/Cart/{customerId}` — Get cart items for a customer (includes slot info)
- `GET /api/Customer/{customerId}/history` — Get purchase history for a customer (includes medicine image path)
- `POST /api/Cart` — Add item to cart
- `PUT /api/Cart/{id}` — Update cart item quantity
- `DELETE /api/Cart/customer/{customerId}` — Delete all cart items for a customer
- `POST /api/Purchase/checkout` — Checkout cart and create purchase
- ...and more (see Swagger docs)

## Environment Variables / Configuration
- `appsettings.json` contains all sensitive and environment-specific settings.
- **Never commit secrets to public repositories!**

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions, suggestions, or support, please open an issue or contact [Mahm0udalaa](https://github.com/Mahm0udalaa). 