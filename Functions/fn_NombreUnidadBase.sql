--
-- Hemoeco Renta (2025)
-- Funcion para obtener el nombre de unidad base a partir del código unidad SAT
--

CREATE OR ALTER FUNCTION dbo.fn_GetNombreUnidadBase(@claveUnidadSAT CHAR(3))
    RETURNS varchar(60)
    AS
    BEGIN
        DECLARE @nombreUnidadComercial varchar(60);

        -- Seleccionar la primer unidad que tenga asignado este código SAT
        SELECT TOP 1 @nombreUnidadComercial = CNOMBREUNIDAD
        FROM Comercial.UnidadMedida
        WHERE CCLAVEINT = @claveUnidadSAT
        ORDER BY CIDUNIDAD 

        RETURN @nombreUnidadComercial;
    END
GO

Grant Execute, view definition on dbo.fn_GetNombreUnidadBase to public;
GO

-- Tests
-- Select * from Comercial.UnidadMedida
-- print dbo.fn_GetNombreUnidadBase('E48') -- SERVICIO
-- print dbo.fn_GetNombreUnidadBase('MON') -- MON
-- print dbo.fn_GetNombreUnidadBase('DAY') -- DIA(S)
