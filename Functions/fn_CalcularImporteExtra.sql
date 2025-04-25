-- ********************************************************************************
-- Hemoeco (2025)
--
-- Función para obtener el importe extra del concepto de factura, siendo que
-- puede provenir de diferentes fuentes dependiendo del tipo de concepto.
--
-- Creado con ayuda de Claude
--
-- ********************************************************************************

CREATE OR ALTER FUNCTION dbo.fn_CalcularImporteExtra(
    @DelAl VARCHAR(50),                    -- Tipo de operación (Venta, Refacción)
    @Cantidad DECIMAL(18,2),               -- Cantidad del movimiento
    @CostoUnitarioRefaccion DECIMAL(18,2), -- Costo unitario de refacción
    @CostoNacionalNuevo DECIMAL(18,2),     -- Costo nacional equipo nuevo
    @CostoNacionalRenta DECIMAL(18,2),     -- Costo nacional equipo renta
    @CostoNacionalUsado DECIMAL(18,2)      -- Costo nacional equipo usado
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN 
        CASE @DelAl
            WHEN 'Venta' THEN 
                ISNULL(@CostoNacionalNuevo, 0) +
                ISNULL(@CostoNacionalRenta, 0) + 
                ISNULL(@CostoNacionalUsado, 0) 
            WHEN 'Refacción' THEN 
                @Cantidad * ISNULL(@CostoUnitarioRefaccion, 0)
            ELSE 0
        END
END
GO

-- Grant permissions
GRANT EXECUTE ON dbo.fn_CalcularImporteExtra TO public
GO

-- Tests
-- print dbo.fn_CalcularImporteExtra('Venta', 1, NULL, 170, 0, 0); -- Expected: 170
-- print dbo.fn_CalcularImporteExtra('Refacción', 2, 50, NULL, NULL, NULL); -- Expected: 100
-- print dbo.fn_CalcularImporteExtra('Renta Equipo', 1, NULL, NULL, NULL, NULL); -- Expected: 0
