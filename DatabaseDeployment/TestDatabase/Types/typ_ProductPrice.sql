CREATE TYPE typ_ProductPrice AS TABLE (
    CountryCode     VARCHAR(3) PRIMARY KEY CLUSTERED,
    Price           DECIMAL (10, 2)
)
