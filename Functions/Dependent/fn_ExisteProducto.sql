--
-- Hemoeco Renta (2025)
-- Funcion para determinar si existe un prodcuto en comercial con 
-- los campos coincidentes
--

CREATE OR ALTER FUNCTION dbo.fn_ExisteProducto(
    @CodigoProducto VARCHAR(30),    -- Código del producto
    @TipoProducto INT,              -- Tipo (1=Venta, 3=Servicio)
    @NombreProducto VARCHAR(60),   -- Nombre del producto
    @ClaveSAT VARCHAR(8)               -- Clave SAT del producto
)
Returns TABLE
AS
RETURN
(
    -- Se crea como función dentro de la carpeta 'wrapers' para utilizar la
    -- tabla directa (servidor.bd.schema.tabla) y no la vista (schema.vista = Comercial.Producto)
    SELECT 1 as Existe
    FROM Comercial.Producto AS p 
    WHERE p.cCodigoProducto = @CodigoProducto 
        AND p.cTipoProducto = @TipoProducto 
        AND p.cNombreProducto = @NombreProducto 
        AND p.cClaveSAT = @ClaveSAT
)
GO

-- Grant permissions
GRANT SELECT ON dbo.fn_ExisteProducto TO public
GO

-- Una alternativa para esta función se muestra a continuación. 
-- Sin embargo esta resulta ineficiente, las medidas de profiler:
-- CPU = 5813, Reads = 18, Writes = 0, Duration = 125377 ms
-- CREATE OR ALTER FUNCTION dbo.fn_ExisteProducto(
--     @CodigoProducto VARCHAR(20),    -- Código del producto
--     @TipoProducto INT,              -- Tipo (1=Venta, 3=Servicio)
--     @NombreProducto VARCHAR(100),   -- Nombre del producto
--     @ClaveSAT VARCHAR(8)           -- Clave SAT del producto
-- )
-- RETURNS BIT
-- AS
-- BEGIN
--     DECLARE @Existe BIT = 0

--     IF EXISTS (
--         SELECT 1 
--         FROM serverContabilidad.adhemoeco_prueba.dbo.admProductos AS p 
--         WHERE p.cCodigoProducto = @CodigoProducto 
--             AND p.cTipoProducto = @TipoProducto 
--             AND p.cNombreProducto = @NombreProducto 
--             AND p.cClaveSAT = @ClaveSAT
--     )
--         SET @Existe = 1

--     RETURN @Existe
-- END
-- GO

-- GRANT EXECUTE ON dbo.fn_ExisteProducto TO public
-- GO

-- drop function dbo.fn_ExisteProducto

