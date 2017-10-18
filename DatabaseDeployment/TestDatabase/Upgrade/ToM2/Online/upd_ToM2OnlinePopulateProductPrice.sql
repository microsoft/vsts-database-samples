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
GO
IF NOT EXISTS (
    SELECT  *
    FROM    sys.triggers
    WHERE   name = 'trg_tbl_Product_Price'
            AND parent_id = OBJECT_ID('tbl_Product')
)
BEGIN
    EXEC sp_executesql N'
    CREATE TRIGGER trg_tbl_Product_Price ON tbl_Product
    FOR INSERT, UPDATE, DELETE
    AS
    BEGIN
        DELETE  pp
        FROM    deleted d
        JOIN    tbl_ProductPrice pp
        ON      pp.ProductId = d.ProductId

        INSERT   tbl_ProductPrice (ProductId, CountryCode, Price)
        SELECT   a.ProductId, b.CountryCode, b.NewPrice
        FROM     inserted a
        CROSS APPLY (
            SELECT  ''USA'' AS CountryCode, a.Price AS NewPrice
            UNION ALL
            SELECT  ''AUS'', a.Price * 1.33 
            UNION ALL
            SELECT  ''CAN'', a.Price * 1.33   
        ) AS b
    END'
END
GO
-- go through tbl_Product in batches of < 5000 to avoid lock escalation.
DECLARE @productStart   INT = 0
DECLARE @productEnd     INT

SELECT  TOP 1 
        @productEnd = ProductId 
FROM    tbl_Product
ORDER BY ProductId DESC

WHILE (@productStart < @productEnd)
BEGIN
    INSERT   tbl_ProductPrice (ProductId, CountryCode, Price)
    SELECT   a.ProductId, b.CountryCode, b.NewPrice
    FROM     tbl_Product a WITH (UPDLOCK, HOLDLOCK)
    CROSS APPLY (
        SELECT  'USA' AS CountryCode, a.Price AS NewPrice
        UNION ALL
        SELECT  'AUS', a.Price * 1.33 
        UNION ALL
        SELECT  'CAN', a.Price * 1.33   
    ) AS b
    WHERE   a.ProductId BETWEEN @productStart AND @productStart + 4000
            AND NOT EXISTS (
            SELECT  *
            FROM    tbl_ProductPrice pp
            WHERE   pp.ProductId = a.ProductId
                    AND pp.CountryCode = b.CountryCode    
            )

    SET @productStart = @productStart + 4001
END