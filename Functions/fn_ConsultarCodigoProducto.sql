-- ***********************************************************
-- (c) 2025 Hemoeco
--
-- Función compartida para determinar si existe un código de
-- producto en Comercial que coincida con los datos de un
-- concepto personalizado de Score
--
-- ***********************************************************
CREATE OR ALTER FUNCTION fn_ConsultarCodigoProducto (
    @descripcion VARCHAR(100),
    @claveProdServ CHAR(8), -- SAT
    @claveUnidad CHAR(3)    -- SAT
)
RETURNS VARCHAR(30) --CCODIGOPRODUCTO
AS
BEGIN
    DECLARE @codigoProducto VARCHAR(30);

    SELECT @codigoProducto = CCODIGOPRODUCTO
    FROM [Comercial].[ProductoYUnidad]
    WHERE 
        @descripcion LIKE CNOMBREPRODUCTO + '%'  -- La descripción debe iniciar con CNOMBREPRODUCTO
        AND @claveProdServ = claveProdServSAT
        AND @claveUnidad = claveUnidadSAT;

    RETURN @codigoProducto;
END;
GO

Grant Execute, view definition on dbo.fn_ConsultarCodigoProducto to public;
GO

-- -- Test
-- -----DATOS concepto pers
-- DECLARE @descripcion VARCHAR(100), @claveUnidad VARCHAR(20), @claveProdServ VARCHAR(20);
-- SET @descripcion = 'RENTA de SOLDADORA A DIESEL, Modelo: DGW4X2DM'
-- SET @claveUnidad = 'E48'
-- SET @claveProdServ = '72141700'

-- SELECT dbo.fn_ConsultarCodigoProducto(@descripcion, @claveProdServ, @claveUnidad) -- RENSERV

-- Print dbo.fn_ConsultarCodigoProducto('Renta de generador MDW500', '72141700', 'DAY') -- REN
-- Print dbo.fn_ConsultarCodigoProducto('Servicio a obra', '72101500', 'E48') -- SRV
-- Print dbo.fn_ConsultarCodigoProducto('Anticipo de renta', '84111506', 'ACT') -- ANT