CREATE TABLE [dbo].[tbl_Product]
(
    [ProductId] INT IDENTITY(1, 1) NOT NULL, 
    [Name] NVARCHAR(100) NOT NULL, 
    [Price] DECIMAL(10, 2) NOT NULL,

    CONSTRAINT PK_tbl_Product PRIMARY KEY CLUSTERED  (ProductId)
)
