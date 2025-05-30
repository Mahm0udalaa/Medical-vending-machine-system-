BEGIN TRANSACTION;
ALTER TABLE [Customers] ADD [Role] nvarchar(max) NOT NULL DEFAULT N'';

ALTER TABLE [Admins] ADD [Role] nvarchar(max) NOT NULL DEFAULT N'';

CREATE TABLE [RefreshTokens] (
    [Id] int NOT NULL IDENTITY,
    [Token] nvarchar(max) NOT NULL,
    [ExpiresAt] datetimeoffset NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [IsRevoked] bit NOT NULL,
    [IsUsed] bit NOT NULL,
    [AdminId] int NULL,
    [CustomerId] int NULL,
    CONSTRAINT [PK_RefreshTokens] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_RefreshTokens_Admins_AdminId] FOREIGN KEY ([AdminId]) REFERENCES [Admins] ([AdminId]) ON DELETE CASCADE,
    CONSTRAINT [FK_RefreshTokens_Customers_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [Customers] ([CustomerId]) ON DELETE CASCADE
);

CREATE INDEX [IX_RefreshTokens_AdminId] ON [RefreshTokens] ([AdminId]);

CREATE INDEX [IX_RefreshTokens_CustomerId] ON [RefreshTokens] ([CustomerId]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250405012700_Tokenauth', N'9.0.3');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250405131604_UpdatedDtoImplementation', N'9.0.3');

DECLARE @var sysname;
SELECT @var = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Customers]') AND [c].[name] = N'Role');
IF @var IS NOT NULL EXEC(N'ALTER TABLE [Customers] DROP CONSTRAINT [' + @var + '];');
ALTER TABLE [Customers] ADD DEFAULT N'Customer' FOR [Role];

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Admins]') AND [c].[name] = N'Role');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Admins] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Admins] ADD DEFAULT N'Admin' FOR [Role];

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250405132645_FixColumnMappings', N'9.0.3');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250405132931_FixColumnNames', N'9.0.3');

COMMIT;
GO

