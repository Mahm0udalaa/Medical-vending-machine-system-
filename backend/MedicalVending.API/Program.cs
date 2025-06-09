using Microsoft.EntityFrameworkCore;
using MedicalVending.Infrastructure.DataBase;
using Microsoft.Extensions.DependencyInjection;
using MedicalVending.Domain.Interfaces;
using MedicalVending.Infrastructure.Repositories;
using MedicalVending.Application.Interfaces;
using MedicalVending.Application.Services;
using MedicalVending.Domain.Entities;
using System.Security.Claims;
using MedicalVending.API.Middleware;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.Azure.Devices;
using MedicalVending.Infrastructure.Services;
using System.Collections.Generic;
using Microsoft.Extensions.Azure;
using Microsoft.AspNetCore.Identity;
using AutoMapper;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

// Add Database Connection
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions => sqlOptions.MigrationsAssembly("MedicalVending.Infrastructure")
            .EnableRetryOnFailure()
    )
);

// Register application services and repositories
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<IMedicineService, MedicineService>();
builder.Services.AddScoped<IMachineMedicineService, MachineMedicineService>();
builder.Services.AddScoped<IPurchaseService, PurchaseService>();
builder.Services.AddScoped<IPurchaseMedicineService, PurchaseMedicineService>();
builder.Services.AddScoped<IVendingMachineService>(sp =>
{
    var machineRepository = sp.GetRequiredService<IVendingMachineRepository>();
    var medicineRepository = sp.GetRequiredService<IMedicineRepository>();
    var mapper = sp.GetRequiredService<IMapper>();
    
    return new VendingMachineService(machineRepository, medicineRepository, mapper);
});
builder.Services.AddScoped<IFavoritesMedicineService, FavoritesMedicineService>();

builder.Services.AddScoped<IAdminRepository, AdminRepository>();
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();
builder.Services.AddScoped<IMedicineRepository, MedicineRepository>();
builder.Services.AddScoped<IMachineMedicineRepository, MachineMedicineRepository>();
builder.Services.AddScoped<IPurchaseRepository, PurchaseRepository>();
builder.Services.AddScoped<IPurchaseMedicineRepository, PurchaseMedicineRepository>();
builder.Services.AddScoped<IVendingMachineRepository, VendingMachineRepository>();
builder.Services.AddScoped<IFavoritesMedicineRepository, FavoritesMedicineRepository>();

// Register the AuthService
builder.Services.AddScoped<IAuthService, MedicalVending.Infrastructure.Services.AuthService>();

// Add Email Services
builder.Services.AddScoped<IEmailVerificationService, EmailVerificationService>();
builder.Services.AddScoped<IEmailSender, SmtpEmailSender>();

// JWT Authentication configuration
var jwtSettings = builder.Configuration.GetSection("Jwt");
var keyString = jwtSettings["Key"] ?? throw new InvalidOperationException("JWT Key is not configured in appsettings.json");
var key = Encoding.UTF8.GetBytes(keyString);
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"] ?? throw new InvalidOperationException("JWT Issuer is not configured"),
        ValidAudience = jwtSettings["Audience"] ?? throw new InvalidOperationException("JWT Audience is not configured"),
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.Zero
    };
});

// Add authorization policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => 
    {
        policy.RequireAuthenticatedUser();
        policy.RequireRole("Admin");
    });
    
    options.AddPolicy("CustomerOnly", policy => 
    {
        policy.RequireAuthenticatedUser();
        policy.RequireRole("Customer");
    });
    
    options.AddPolicy("AllUsers", policy => 
    {
        policy.RequireAuthenticatedUser();
        policy.RequireRole(new[] { "Admin", "Customer" });
    });
});

// Add services to the container.
builder.Services.AddControllers();

// Add CORS policy
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowClientApp", 
        policyBuilder => policyBuilder
            .SetIsOriginAllowed(_ => true)
            .AllowAnyMethod()
            .AllowAnyHeader()
            .WithExposedHeaders("Content-Disposition"));
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Medical Vending API",
        Version = "v1",
        Description = "API for the Medical Vending Machine system",
        Contact = new OpenApiContact
        {
            Name = "Medical Vending Team",
            Email = "support@medicalvending.com"
        }
    });
    
    // Add JWT Bearer support
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token in the text input below. Example: 'Bearer 12345abcdef'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "Bearer",
                Name = "Bearer",
                In = ParameterLocation.Header,
            },
            new List<string>()
        }
    });

    // Enable XML comments
    try
    {
        var xmlFilename = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
        var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFilename);
        if (File.Exists(xmlPath))
        {
            c.IncludeXmlComments(xmlPath);
        }
    }
    catch (Exception ex)
    {
        // Log the exception but don't throw it to prevent Swagger from failing
        Console.WriteLine($"Warning: XML comments file could not be loaded: {ex.Message}");
    }
});

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

// Add IoT Hub and Dispense service
var iotHubConnectionString = builder.Configuration["AzureIoTHub:ConnectionString"];
builder.Services.AddSingleton(ServiceClient.CreateFromConnectionString(iotHubConnectionString));
builder.Services.AddSingleton(RegistryManager.CreateFromConnectionString(iotHubConnectionString));
builder.Services.AddScoped<IDispenseService, DispenseService>();
builder.Services.AddScoped<IIoTDeviceService>(sp => new IoTDeviceService(iotHubConnectionString));

// Add Blob Storage service
builder.Services.AddScoped<IBlobStorageService, BlobStorageService>();
builder.Services.AddAzureClients(clientBuilder =>
{
    clientBuilder.AddBlobServiceClient(builder.Configuration["AzureStorage:ConnectionString1:blobServiceUri"]!).WithName("AzureStorage:ConnectionString1");
    clientBuilder.AddQueueServiceClient(builder.Configuration["AzureStorage:ConnectionString1:queueServiceUri"]!).WithName("AzureStorage:ConnectionString1");
    clientBuilder.AddTableServiceClient(builder.Configuration["AzureStorage:ConnectionString1:tableServiceUri"]!).WithName("AzureStorage:ConnectionString1");
});

// Add Token Cleanup Service
builder.Services.AddHostedService<TokenCleanupService>();

builder.Services.AddScoped<IPasswordHasher<Customer>, MedicalVending.Application.Services.BCryptPasswordHasher>();
builder.Services.AddScoped<ICartRepository, CartRepository>();

// Add rate limiting
RateLimitingMiddleware.ConfigureRateLimiting(builder.Services);

// Add response caching
ResponseCachingMiddleware.ConfigureResponseCaching(builder.Services);

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseSwagger(options => 
{
    options.SerializeAsV2 = false;
    options.RouteTemplate = "{documentName}/swagger.json";
});

app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/v1/swagger.json", "Medical Vending API V1");
    options.RoutePrefix = "swagger";
    options.DocExpansion(Swashbuckle.AspNetCore.SwaggerUI.DocExpansion.List);
    options.DefaultModelsExpandDepth(-1);
    options.DisplayRequestDuration();
    options.EnableDeepLinking();
});

// Enable CORS first
app.UseCors("AllowClientApp");

// Use routing and other middleware
app.UseRouting();
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();

app.UseMiddleware<ExceptionHandlingMiddleware>();

app.MapControllers();

// Ensure Swagger JSON endpoint is mapped
app.MapSwagger();

// Use rate limiting
app.UseRateLimiter();

// Use response caching
ResponseCachingMiddleware.UseResponseCaching(app);

// Apply pending migrations at startup
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    dbContext.Database.Migrate();
}

app.Run();
