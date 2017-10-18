IF OBJECT_ID('dbo.prc_UpdateProduct', 'P') IS NOT NULL DROP PROCEDURE dbo.prc_UpdateProduct;
IF OBJECT_ID('dbo.prc_GetProduct', 'P') IS NOT NULL DROP PROCEDURE dbo.prc_GetProduct;
IF OBJECT_ID('dbo.prc_CreateProduct', 'P') IS NOT NULL DROP PROCEDURE dbo.prc_CreateProduct;
GO
-->#(name="tbl_Product" type="TABLE")
IF OBJECT_ID('dbo.tbl_Product', 'U') IS NULL
CREATE TABLE tbl_Product
(
    [ProductId] INT IDENTITY(1, 1) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Price] DECIMAL(10, 2) NOT NULL,

    CONSTRAINT PK_tbl_Product PRIMARY KEY CLUSTERED  (ProductId)
)
GO
-->#(name="prc_CreateProduct" type="PROCEDURE" hash="9B295A294979F94EEFA99B06F82C617D205596CC")
CREATE PROCEDURE prc_CreateProduct
    @name    NVARCHAR(100),
    @price   DECIMAL(10, 2)
AS
SET XACT_ABORT ON
SET NOCOUNT ON

INSERT  tbl_Product(Name, Price)
SELECT  @name, @price

SELECT  @@IDENTITY AS ProductId
RETURN 0
GO
-->#(name="prc_GetProduct" type="PROCEDURE" hash="3119AFC6C291F8922E49F9218E576BEF41CF1B6B")
CREATE PROCEDURE prc_GetProduct
    @productId  INT
AS
SET NOCOUNT ON

SELECT  ProductId,
        Name,
        Price
FROM    tbl_Product
WHERE   ProductId = @productId

RETURN 0
GO
-->#(name="prc_UpdateProduct" type="PROCEDURE" hash="2CF4FE1234927B9E8C733CA49073708E373827B4")
CREATE PROCEDURE prc_UpdateProduct
    @productId      INT,
    @name    NVARCHAR(100),
    @price   DECIMAL(10, 2)
AS
SET NOCOUNT     ON
SET XACT_ABORT  ON

UPDATE  tbl_Product
SET     Name = @name,
        Price = @price
WHERE   ProductId = @productId

RETURN 0
GO
DECLARE @version INT = 1
EXEC sys.sp_addextendedproperty 'DatabaseVersion', @version
GO
