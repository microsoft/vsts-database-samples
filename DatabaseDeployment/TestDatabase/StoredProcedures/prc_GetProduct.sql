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
