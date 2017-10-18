-->#(name="tbl_ProductPrice" type="TABLE")
SET XACT_ABORT ON
-->#(name="tbl_ProductPrice" type="TABLE")
IF OBJECT_ID('dbo.tbl_ProductPrice', 'U') IS NULL
CREATE TABLE tbl_ProductPrice (
    ProductId           INT NOT NULL,
    CountryCode         VARCHAR(3) NOT NULL,
    [Price]             DECIMAL(10, 2) NOT NULL,

    CONSTRAINT PK_tbl_ProductPrice PRIMARY KEY CLUSTERED  (ProductId, CountryCode)
)
IF EXISTS (
    SELECT  *
    FROM    sys.columns
    WHERE   name = 'Price'
            AND object_id = OBJECT_ID('tbl_Product')
)
BEGIN
  BEGIN TRAN

  -- needs to be dynamic SQL for re-runnability
  EXEC sp_executesql N'INSERT   tbl_ProductPrice (ProductId, CountryCode, Price)
                       SELECT   a.ProductId, b.CountryCode, b.NewPrice
                       FROM     tbl_Product a
                       CROSS APPLY (
                            SELECT  ''USA'' AS CountryCode, a.Price AS NewPrice
                            UNION ALL
                            SELECT  ''AUS'', a.Price * 1.33 
                            UNION ALL
                            SELECT  ''CAN'', a.Price * 1.33   
                       ) AS b'


  ALTER TABLE tbl_Product DROP COLUMN Price        
  COMMIT TRAN    
END
