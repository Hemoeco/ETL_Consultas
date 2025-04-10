-- ***********************************************************
-- (c) 2025 Hemoeco
--
-- Función compartida para determinar el código de producto
-- por defecto en Comercial, desde los datos de Score
--
-- Obtenido con ayuda de Claude Sonet, a partir de la
-- consulta original 'Movimientos'
--
-- ***********************************************************
CREATE OR ALTER FUNCTION [dbo].[fn_ObtenerCodigoProducto]
(
    @MTIPO varchar(50),
    @IDEQUIPONUEVO int,
    @IDEQUIPOUSADO int,
    @DELAL varchar(50),
    @IDLINEA int,
    @IDREFACCION int,
    @XML_ETIQUETA2 varchar(50)
)
RETURNS varchar(50)
AS
BEGIN
    DECLARE @Result varchar(50)

    SELECT @Result = 
        CASE
            -- Conversiones especiales
            WHEN @XML_ETIQUETA2 = 'MANIOBRA' AND @MTIPO = 'servicio a obra' THEN @XML_ETIQUETA2
            WHEN @XML_ETIQUETA2 <> 'MANIOBRA' AND @XML_ETIQUETA2 is not null AND @XML_ETIQUETA2 <> '' AND @MTIPO = 'Renta equipo' THEN @XML_ETIQUETA2
            --
            WHEN IsNull(@IDEQUIPONUEVO, 0) + IsNull(@IDEQUIPOUSADO, 0) <> 0 OR rtrim(@DELAL)='Arrendadora' THEN CONCAT('MOD', @IDLINEA)
            WHEN IsNull(@IDREFACCION, 0) <> 0 THEN CONCAT('REF', @IDREFACCION)
            WHEN @MTIPO = 'Anticipo' THEN 'ANT'
            WHEN @MTIPO = 'Renta Equipo' THEN 'REN'
            ELSE 'SRV'
        END

    RETURN @Result
END
GO

Grant Execute, view definition on dbo.fn_ObtenerCodigoProducto to public;
GO

---- Test
--print dbo.fn_ObtenerCodigoProducto('Renta Equipo', null, null, '08/04/25 al 10/04/25', null, null, '') -- REN
--print dbo.fn_ObtenerCodigoProducto('Renta Equipo', null, null, '08/04/25 al 10/04/25', null, null, 'RENMES') -- RENMES
--print dbo.fn_ObtenerCodigoProducto('Renta Equipo', null, null, '08/04/25 al 10/04/25', null, null, 'MANIOBRA') -- REN
--print dbo.fn_ObtenerCodigoProducto('Servicio a obra', null, null, '08/04/25 al 10/04/25', null, null, 'MANIOBRA') -- MANIOBRA
--print dbo.fn_ObtenerCodigoProducto('Servicio a obra', null, null, 'Centro Cancún', null, null, '') -- SRV
--print dbo.fn_ObtenerCodigoProducto('Venta nuevo', null, null, 'Arrendadora', 123, null, 'MANIOBRA') -- MO123
--print dbo.fn_ObtenerCodigoProducto('Venta nuevo', null, null, 'Arrendadora', 123, null, 'MANIOBRA') -- MOD123
--print dbo.fn_ObtenerCodigoProducto('Venta usado', 2222, null, '', 2427, null, 'MANIOBRA') -- MOD2427
--print dbo.fn_ObtenerCodigoProducto('Anticipo', null, null, '', null, null, '') -- ANT
--print dbo.fn_ObtenerCodigoProducto('Refacción', null, null, '', null, 2244, '') -- REF2244

