-- ********************************************************************************
-- Hemoeco (2025)
--
-- Función para obtener el costo específico del concepto de factura, siendo que
-- puede provenir de diferentes fuentes dependiendo del tipo de concepto.
--
-- Creado con ayuda de Claude
--
-- ********************************************************************************

CREATE OR ALTER FUNCTION dbo.fn_CalcularCostoEspecifico(
    @DelAl VARCHAR(50),                    -- Tipo de operación (Venta, Refacción, etc.)
    @Cantidad DECIMAL(18,2),               -- Cantidad del movimiento
    @CostoUnitarioRefaccion DECIMAL(18,2), -- Costo unitario de refacción
    @CostoNacionalEquipoNuevo DECIMAL(18,2), -- Costo nacional equipo nuevo
    @CostoNacionalEquipoRenta DECIMAL(18,2), -- Costo nacional equipo renta
    @CostoNacionalEquipoUsado DECIMAL(18,2)  -- Costo nacional equipo usado
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN 
        CASE @DelAl 
            WHEN 'Venta' THEN 
                ISNULL(@CostoNacionalEquipoNuevo, 0) +
                ISNULL(@CostoNacionalEquipoRenta, 0) + 
                ISNULL(@CostoNacionalEquipoUsado, 0) 
            WHEN 'Refacción' THEN 
                @Cantidad * ISNULL(@CostoUnitarioRefaccion, 0)
            ELSE 0 
        END
END
GO

-- Grant permissions
GRANT EXECUTE ON dbo.fn_CalcularCostoEspecifico TO public
GO

-- Tests
-- print dbo.fn_CalcularCostoEspecifico('Venta', 1, NULL, 170, 0, 0); -- Expected: 170
-- print dbo.fn_CalcularCostoEspecifico('Venta', 1, NULL, NULL, 270, 0); -- Expected: 270
-- print dbo.fn_CalcularCostoEspecifico('Refacción', 2, 50, NULL, NULL, NULL); -- Expected: 100
-- print dbo.fn_CalcularCostoEspecifico('Anticipo', 1, NULL, NULL, NULL, NULL); -- Expected: 0
