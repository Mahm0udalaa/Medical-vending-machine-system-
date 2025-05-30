CREATE TABLE EmailVerificationCodes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL,
    Code NVARCHAR(MAX) NOT NULL,
    ExpirationTime DATETIME2 NOT NULL
);

CREATE INDEX IX_EmailVerificationCodes_UserId_ExpirationTime ON EmailVerificationCodes (UserId, ExpirationTime); 