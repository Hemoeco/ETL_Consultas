-- ***********************************************************
-- (c) 2025 Hemoeco
--
-- Función encapsulada para formar el código de producto
-- a importar en Comercial para un concpeto personalizado 
-- de Score que no tiene equivalente.
--
-- ***********************************************************
CREATE OR ALTER FUNCTION fn_CrearCodigoProdPers (
    @TipoConFac CHAR(15),
    @claveProdServ CHAR(8), -- SAT
    @claveUnidad CHAR(3)   -- SAT
)
RETURNS VARCHAR(30) --CCODIGOPRODUCTO
AS
BEGIN
    DECLARE @codigoProducto VARCHAR(30) = Concat(
        case rtrim(@TipoConFac) 
            when 'Refacción' then 'REF'
            when 'Venta Nuevo' then 'MOD'
            when 'Venta Usado' then 'MOD'
            when 'Anticipo' then 'ANT'
            when 'Renta Equipo' then 'REN'
            else 'SRV' end,
            '-',
            @claveProdServ,
            '-',
            @claveUnidad
    );

    RETURN @codigoProducto;
END;
GO

Grant Execute, view definition on dbo.fn_ConsultarCodigoProducto to public;
GO

-- -- Test
-- print dbo.fn_CrearCodigoProdPers('Refacción      ', '72141700', 'E48') -- REF-72141700-E48
-- print dbo.fn_CrearCodigoProdPers('Venta Nuevo    ', '72141700', 'E48') -- MOD-72141700-E48
-- print dbo.fn_CrearCodigoProdPers('Venta Usado    ', '72141700', 'E48') -- MOD-72141700-E48
-- print dbo.fn_CrearCodigoProdPers('Anticipo       ', '72141700', 'E48') -- ANT-72141700-E48
-- print dbo.fn_CrearCodigoProdPers('Renta Equipo   ', '72141700', 'E48') -- REN-72141700-E48
-- print dbo.fn_CrearCodigoProdPers('Servicio a Obra', '72101500', 'E48') -- SRV-72141700-E48
-- print dbo.fn_CrearCodigoProdPers('Mano de Obra   ', '72141700', 'E48') -- SRV-72141700-E48