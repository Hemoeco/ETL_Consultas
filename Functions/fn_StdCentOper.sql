-- ***********************************************************
-- 2025 Hemoeco
--
-- Estandariza el centro operativo o sucursal para 2 digitos
-- relleno de ceros a la izquierda
--
-- ***********************************************************

CREATE or ALTER FUNCTION dbo.fn_StdCentOper(
    @idCentOper INT
)
RETURNS CHAR(2)
AS
BEGIN
    RETURN RIGHT(CONCAT('00', @idCentOper), 2)
END
GO

Grant Execute, view definition on dbo.fn_StdCentOper to public;

-- test
-- select dbo.fn_StdCentOper(1) as 'Sucursal 1',
--        dbo.fn_StdCentOper(5) as 'Sucursal 1',
--        dbo.fn_StdCentOper(10) as 'Sucursal 10',
--        dbo.fn_StdCentOper(99) as 'Sucursal 99'
