/*****************************************************************************
* Description of prc_UpdateProduct goes here
*****************************************************************************/
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