-- ********************************************************************************
-- Hemoeco (2025)
--
-- Función para obtener una descripción lista para concatenar con el
-- nombre del producto, con las excepciones necesarias, por ejemplo el código
-- 'RENTA.' que requiere una descripción exacta como 'Orden_de_compra_####_renta' 
--
-- Esto se requiere ya que Comercial concatena el nombre del producto y las observaciones
-- para obtener la descripción del concepto que se timbra.
-- ver: https://drive.google.com/file/d/1o9FARzXxr66fHBa8--rL0N0P861E9Rem/view?usp=drive_link
--
-- Se comparte entre ETL (Movimientos) y Score (FacturaImpresionPrevia)
-- ********************************************************************************

CREATE OR ALTER FUNCTION dbo.fn_AdaptarDescripcionObservacion(
    @MTIPO CHAR(15),              -- OperConFac
    @Descripcion VARCHAR(MAX),    -- OperConFac.Descripcion --> admMovimientos.cObservaMov
    @cCodigoProducto VARCHAR(30), -- View_CodigosSAT_ETL / admProductos
    @cNombreProducto VARCHAR(60)  -- View_CodigosSAT_ETL / admProductos
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    -- Código fuente en Github: https://github.com/Hemoeco/ETL_Consultas

    IF @Descripcion IS NULL and @cNombreProducto IS NULL
        RETURN NULL;

    -- paso 1. Quitamos la primera parte de descripción si coincide con el nombre de producto.
    -- Con esto evitamos una descripción final tipo: "RENTARenta de compresor..." para obtener: "RENTA de compresor..."
    Declare @offset int = IIF(CHARINDEX(@cNombreProducto, @Descripcion) = 1, LEN(@cNombreProducto), 0);
    Declare @DescrSinCodigoRepetido varchar(max) = RTRIM(SUBSTRING(@Descripcion, @offset + 1, LEN(@Descripcion)));

    -- separador si no es código especial ("RENTA.") o si empieza con espacio. En cualquier otro caso
    Declare @separador varchar(2) = IIF(
            (RTrim(@MTIPO) = 'Renta Equipo' AND @cCodigoProducto = 'RENTA.') OR SUBSTRING(@DescrSinCodigoRepetido, 1, 1) = ' ',
            '',
            ' '
        );

    -- La descripción del concepto en Score pasa a las observaciones de Movimiento en Comercial, 
    -- sin el nombre del producto, ya que la descripción del concepto cfdi se forma con el nombre del producto + observaciones 
    RETURN CONCAT(@separador, @DescrSinCodigoRepetido);
END
GO

Grant Execute, view definition on dbo.fn_AdaptarDescripcionObservacion to public;

-- Tests :
-- -- Para probar, descomentar y correr
-- PRINT IIF((dbo.fn_AdaptarDescripcionObservacion('Renta Equipo', NULL, 'REN', 'RENTA') IS NULL), 'Exito', 'Falla - NULL not handled');
-- PRINT IIF((dbo.fn_AdaptarDescripcionObservacion('Renta Equipo', 'Descripcion', 'REN', NULL) IS NULL), 'Exito', 'Falla - NULL not handled');

-- -- todo: this test renders 'Falla' instead of 'Exito.
-- -- DECLARE @result varchar(max) = dbo.fn_AdaptarDescripcionObservacion('Renta equipo', 'Renta de plataforma', 'REN', 'RENTA'); 
-- -- PRINT CONCAT('"', @result, '"'); -- Check for spaces
-- -- Print IIF(@result = 'Renta de plataforma', 'Exito', 'Falla');

-- print dbo.fn_AdaptarDescripcionObservacion('Renta equipo', 'Renta de plataforma', 'REN', 'RENTA'); -- RENTA de plataforma
-- print dbo.fn_AdaptarDescripcionObservacion('Renta equipo', 'Orden_de_compra_1234_Renta de apisonador', 'RENTA.', 'Orden'); -- Orden_de_compra_1234_Renta de apisonador
-- print dbo.fn_AdaptarDescripcionObservacion('Refacción', 'Tuerca de sujeción 1/2', 'REF123', 'VENTA REFACCION'); -- VENTA REFACCION Tuerca de sujeción 1/2
-- print dbo.fn_AdaptarDescripcionObservacion('Servicio a obra', 'Pickup Nissan Cancún Centro', 'SRV', 'SERVICIO'); -- SERVICIO Pickup Nissan Cancún Centro
-- print dbo.fn_AdaptarDescripcionObservacion('Servicio a obra', 'Logistica maniobra terrestre', 'MANIOBRA', 'LOGISTICA MANIOBRA TERRESTRE'); -- LOGISTICA MANIOBRA TERRESTRE