IF EXISTS (
    SELECT  *
    FROM    sys.triggers
    WHERE   name = 'trg_tbl_Product_Price'
            AND parent_id = OBJECT_ID('tbl_Product')
)
BEGIN
    DROP TRIGGER trg_tbl_Product_Price
END
GO
IF EXISTS (
    SELECT  *
    FROM    sys.columns
    WHERE   name = 'Price'
            AND object_id = OBJECT_ID('tbl_Product')
)
BEGIN
  ALTER TABLE tbl_Product DROP COLUMN Price        
END
GO
