DECLARE @version INT = 2

IF NOT EXISTS (
    select * FROM  fn_listextendedproperty('DatabaseVersion', default, default, default, default, default, default)
)
BEGIN
    EXEC sys.sp_addextendedproperty 'DatabaseVersion', @version
END
ELSE
BEGIN
    EXEC sys.sp_updateextendedproperty 'DatabaseVersion', @version    
END