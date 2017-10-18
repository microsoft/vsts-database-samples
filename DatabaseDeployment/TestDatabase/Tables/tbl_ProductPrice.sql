CREATE TABLE tbl_ProductPrice (
    ProductId           INT NOT NULL,
    CountryCode         VARCHAR(3) NOT NULL,
    [Price]             DECIMAL(10, 2) NOT NULL,           

    CONSTRAINT PK_tbl_ProductPrice PRIMARY KEY CLUSTERED  (ProductId, CountryCode)
)
