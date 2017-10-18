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
