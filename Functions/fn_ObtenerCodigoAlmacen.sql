-- ***********************************************************
-- 2025 Hemoeco
--
-- Obtiene el código de almacen de Comercial para 
-- los diferentes tipos de concepto
--
-- código obtenido con ayuda de IA Claude
--
-- ***********************************************************

CREATE OR ALTER FUNCTION dbo.fn_ObtenerCodigoAlmacen(
    @idSucursal INT,
    @idEquipoNuevo INT,
    @idEquipoUsado INT,
    @idRefaccion INT,
    @mTipo VARCHAR(50),
    @delAl VARCHAR(50)
)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CONCAT(dbo.fn_StdCentOper(@idSucursal),
        CASE 
            WHEN @idEquipoNuevo <> 0 OR RTRIM(@delAl)='Arrendadora' THEN 'ENUE'
            WHEN @idRefaccion <> 0 THEN 'REFA'
            WHEN @idEquipoUsado <> 0 THEN 'EUSA'
            WHEN @mTipo = 'Anticipo' THEN 'ANT'
            WHEN @mTipo = 'Renta Equipo' THEN 'EREN' 
            ELSE 'OTR'
        END)
END
GO

Grant Execute, view definition on dbo.fn_ObtenerCodigoAlmacen to public;

-- Tests
-- print dbo.fn_ObtenerCodigoAlmacen(1, 1, 0, 0, '', '') -- '01ENUE'
-- print dbo.fn_ObtenerCodigoAlmacen(2, 1, 0, 0, '', 'Arrendadora') -- '02ENUE'
-- print dbo.fn_ObtenerCodigoAlmacen(4, 0, 333, 0, '', '') -- '04EUSA'
-- print dbo.fn_ObtenerCodigoAlmacen(3, 0, 0, 1, '', '') -- '03REFA'
-- print dbo.fn_ObtenerCodigoAlmacen(5, 0, 0, 0, 'Anticipo', '') -- '05ANT'
-- print dbo.fn_ObtenerCodigoAlmacen(8, 0, 0, 0, 'Renta Equipo', '') -- '08EREN'
-- print dbo.fn_ObtenerCodigoAlmacen(10, 0, 0, 0, 'Renta Equipo', '') -- '10EREN'
