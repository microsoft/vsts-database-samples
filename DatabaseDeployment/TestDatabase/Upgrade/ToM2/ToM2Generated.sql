IF OBJECT_ID('dbo.prc_UpdateProduct', 'P') IS NOT NULL DROP PROCEDURE dbo.prc_UpdateProduct;
IF OBJECT_ID('dbo.prc_GetProduct', 'P') IS NOT NULL DROP PROCEDURE dbo.prc_GetProduct;
IF OBJECT_ID('dbo.prc_CreateProduct', 'P') IS NOT NULL DROP PROCEDURE dbo.prc_CreateProduct;
GO
-->#(name="typ_ProductPrice" type="TYPE" kind="TABLETYPE")
IF NOT EXISTS(SELECT * FROM sys.types WHERE name = 'typ_ProductPrice' AND schema_id = SCHEMA_ID('dbo'))
CREATE TYPE typ_ProductPrice AS TABLE (
    CountryCode     VARCHAR(3) PRIMARY KEY CLUSTERED,
    Price           DECIMAL (10, 2)
)
-->#(name="tbl_ProductPrice" type="TABLE")
IF OBJECT_ID('dbo.tbl_ProductPrice', 'U') IS NULL
CREATE TABLE tbl_ProductPrice (
    ProductId           INT NOT NULL,
    CountryCode         VARCHAR(3) NOT NULL,
    [Price]             DECIMAL(10, 2) NOT NULL,

    CONSTRAINT PK_tbl_ProductPrice PRIMARY KEY CLUSTERED  (ProductId, CountryCode)
)
GO
-->#(name="prc_CreateProduct" type="PROCEDURE" hash="314DB7A83B2507A391483623CEC3389DAA17AE31")
CREATE PROCEDURE prc_CreateProduct
    @name    NVARCHAR(100),
    @prices  typ_ProductPrice READONLY
AS
SET XACT_ABORT ON
SET NOCOUNT ON

DECLARE @productId  INT
BEGIN TRAN

INSERT  tbl_Product(Name)
SELECT  @name

SELECT  @productId = @@IDENTITY

INSERT  tbl_ProductPrice(ProductId, CountryCode, Price)
SELECT  @productId,
        CountryCode,
        Price
FROM    @prices

COMMIT TRAN

SELECT  @productId AS ProductId

RETURN 0
GO
-->#(name="prc_GetProduct" type="PROCEDURE" hash="9C84C8D4191BC5F3FC04CEB17C7E64AA08BCCAF3")
CREATE PROCEDURE prc_GetProduct
    @productId  INT
AS
SET NOCOUNT ON

SELECT  ProductId,
        Name
FROM    tbl_Product
WHERE   ProductId = @productId

SELECT  CountryCode,
        Price
FROM    tbl_ProductPrice
WHERE   ProductId = @productId

RETURN 0
GO
-->#(name="prc_UpdateProduct" type="PROCEDURE" hash="EC46966714F30A9FD484237CCBD42983CAC3E10D")
CREATE PROCEDURE prc_UpdateProduct
    @productId      INT,
    @name    NVARCHAR(100),
    @prices  typ_ProductPrice READONLY
AS
SET NOCOUNT     ON
SET XACT_ABORT  ON

BEGIN TRAN

UPDATE  tbl_Product
SET     Name = @name
WHERE   ProductId = @productId

MERGE   tbl_ProductPrice pp
USING   @prices i
ON      pp.CountryCode = i.CountryCode
        AND pp.ProductId = @productId
WHEN MATCHED THEN
UPDATE SET Price = i.Price
WHEN NOT MATCHED BY TARGET THEN
INSERT (ProductId, CountryCode, Price)
VALUES (@productId, i.CountryCode, i.Price)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;

COMMIT TRAN

RETURN 0
GO
DECLARE @version INT = 2
EXEC sys.sp_updateextendedproperty 'DatabaseVersion', @version
GO
