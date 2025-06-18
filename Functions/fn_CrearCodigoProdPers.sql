-- ***********************************************************
-- (c) 2025 Hemoeco
--
-- Función encapsulada para formar el código de producto
-- a importar en Comercial para un concepto personalizado 
-- de Score que no tiene equivalente.
--
-- ***********************************************************
CREATE OR ALTER FUNCTION fn_CrearCodigoProdPers (
    @TipoConFac CHAR(15),
    @claveProdServ CHAR(8), -- SAT
    @claveUnidad CHAR(3),  -- SAT
    @descrip VARCHAR(1000) -- Score
)
RETURNS VARCHAR(30) --CCODIGOPRODUCTO
AS
BEGIN
    declare @PrimerPalabraDesc varchar(60) = dbo.fn_PrimerPalabra(@descrip);

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
            @claveUnidad,
            '-',
            @PrimerPalabraDesc
    );

    -- -- debug try
    -- declare @TipoConFac CHAR(15) = 'Mano de obra',
    -- @claveProdServ CHAR(8) = '72141700', -- SAT
    -- @claveUnidad CHAR(3) = 'E48',  -- SAT
    -- @descrip VARCHAR(1000) = 'Reparacion de maquina' -- Score

    -- print @codigoProducto

    if (debug.fn_HemoecoDebugIsEnabled() = 1)
    begin
        -- Verificar si el producto podrá importarse, aplicar las mismas condiciones que 'fn_ConsultarCodigoProducto'
        -- mantener en sincronía estas condiciones en 'fn_CrearCodigoProdPers' (aqui) y 'fn_ConsultarCodigoProducto'
        declare @comercial_descr varchar(60),
                @comercial_claveProdServ varchar(8),
                @comercial_claveUnidad varchar(3)

        Select @comercial_descr = CNOMBREPRODUCTO,
                @comercial_claveProdServ = claveProdServSAT,
                @comercial_claveUnidad = claveUnidadSAT
            from Comercial.ProductoYUnidad 
                where CCODIGOPRODUCTO = @codigoProducto 

        if ( @comercial_descr is not null
            and (@descrip not like @comercial_descr + '%'
                or @claveProdServ <> @comercial_claveProdServ
                or @claveUnidad <> @comercial_claveUnidad) )
        begin
            -- Si marca este error, es porque el código de producto ya está registrado y la descripción no coincide,
            -- en este caso, necesitan dar de alta el producto en Comercial para que pueda importarse correctamente
            -- deben coincidir: Clave prod/serv, Clave unidad y la primer palabra de score.descripcion con comercial.producto.cNombreProducto
            -- debug try
            declare @err varchar(max) = Concat(
                'Dar de alta el producto antes de importar.',
                ' Los valores para la clave de producto ', 
                @codigoProducto,
                ' no coinciden con los requeridos.',
                ' Valores en comercial: ',
                @comercial_descr, ', ',
                @comercial_claveProdServ, ',',
                @comercial_claveUnidad,'.',
                ' Valores en Score: ',
                rtrim(@TipoConFac), ',',
                @descrip, ',',
                @claveProdServ, ',',
                @claveUnidad, ',',
                'primer palabra: "', @PrimerPalabraDesc, '"',
                ' Diferencias en:' );
            -- print @err
            if (@descrip not like @comercial_descr + '%')
                set @err = Concat(@err, ' Nombre.');
            if (@claveProdServ <> @comercial_claveProdServ)
                set @err = Concat(@err, char(10), ' Clave prod/serv.');
            if (@claveUnidad <> @comercial_claveUnidad)
                set @err = Concat(@err, char(10), ' Clave unidad.');

            -- this will raise an exception
            -- trick from
            -- https://stackoverflow.com/questions/15836759/throw-exception-from-sql-server-function-to-stored-procedure
            declare @errb bit = @err
        end
    end

    RETURN @codigoProducto;
END;
GO

Grant Execute, view definition on dbo.fn_ConsultarCodigoProducto to public;
GO

-- -- Test
-- exec debug.sp_EnableHemoecoDebug
-- exec debug.sp_DisableHemoecoDebug
-- print dbo.fn_CrearCodigoProdPers('Refacción      ', '72141700', 'E48', 'Prueba') -- REF-72141700-E48-Prueba
-- print dbo.fn_CrearCodigoProdPers('Venta Nuevo    ', '72141700', 'E48', 'Prueba') -- MOD-72141700-E48-Prueba
-- print dbo.fn_CrearCodigoProdPers('Venta Usado    ', '72141700', 'E48', 'Prueba') -- MOD-72141700-E48-Prueba
-- print dbo.fn_CrearCodigoProdPers('Anticipo       ', '72141700', 'E48', 'Prueba') -- ANT-72141700-E48-Prueba
-- print dbo.fn_CrearCodigoProdPers('Renta Equipo   ', '72141700', 'E48', 'Prueba') -- REN-72141700-E48-Prueba
-- print dbo.fn_CrearCodigoProdPers('Servicio a Obra', '72101500', 'E48', 'Prueba mano de obra') -- SRV-72141700-E48-Prueba
-- print dbo.fn_CrearCodigoProdPers('Mano de Obra   ', '72141700', 'E48', 'Prueba') -- SRV-72141700-E48-Prueba
-- print dbo.fn_CrearCodigoProdPers('Mano de obra', '72141700', 'E48', 'Reparacion de maquina') -- SRV-72141700-E48-Reparacion

-- Para probar un error, activar 'fn_Debug' crear una clave en Comercial con un dato diferente. Un ejemplo de error se produce si el código no incluye prime palabra
-- Error de conversión al convertir el valor varchar 
-- 'Dar de alta el producto antes de importar. Los valores para la clave de producto SRV-72141700-E48 no coinciden con los requeridos.
--  Valores en comercial: SERV., 72141700,E48.
--  Valores en Score: Mano de obra,Reparacion de maquina,72141700,E48,primer palabra: "Reparacion"
--  Diferencias en: Nombre.' al tipo de datos bit.
