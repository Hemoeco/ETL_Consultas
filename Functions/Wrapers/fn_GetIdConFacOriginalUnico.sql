--
-- Hemoeco Renta (2025)
-- Funciones para obtener el IdConFacOriginal de un concepto agrupado (personalizado)
--
-- Esta funcion tiene una copia adaptada en Score y ETL, mantener en sincronía
-- Se decidió así por ser la manera más simple de compartir el código
-- manteniendo la eficiencia.
-- La copia en ETL agrega el servidor y la base de datos a la llamada

CREATE OR ALTER FUNCTION fn_EsConceptoRenta(@tipoCon VARCHAR(MAX))
    RETURNS BIT
    AS 
    BEGIN
      RETURN CASE WHEN @tipoCon = 'Renta Equipo' THEN 1 ELSE 0 END
    END
GO

Grant Execute, view definition on dbo.fn_EsConceptoRenta to public;
GO

CREATE OR ALTER FUNCTION dbo.fn_GetIdConFacOriginalUnico(@IdOperConFacPers UNIQUEIDENTIFIER)
    RETURNS INT
    AS
    BEGIN
        -- Esta función regresa el id del concepto original relacionado de factura, de acuerdo
        -- con las reglas descritas en el manual de usuario de factura personalizada:
        -- https://docs.google.com/document/d/1VK5YB8GKPjwxlQ07rNC7yu-P3OIGLPvqHH0jBlqUjSA/edit?tab=t.pttj9yugaae3#heading=h.h6yhrm9d38hj

        DECLARE @IdConFacOriginalPrincipal INT;

        -- CTE para obtener los conceptos relacionados al ID, junto con el indicador de si es de renta
        WITH CTE_Conceptos AS (
            SELECT 
                o.IDCONFAC,
                o.IMPORTE,
                -- Evaluamos si el concepto es de tipo renta (1 = sí, 0 = no)
                EsRenta = dbo.fn_EsConceptoRenta(o.MTIPO)
            FROM serverScore.IT_Rentas_Pruebas.dbo.rlnOperConFac_OperConFacPers r
            INNER JOIN serverScore.IT_Rentas_Pruebas.dbo.OperConFac o ON r.IDCONFAC = o.IDCONFAC
            WHERE r.IDCONFACPERS = @IdOperConFacPers
        )
        -- Seleccionamos el concepto correcto según las siguientes prioridades:
        -- 1. Si hay al menos un concepto de renta, se elige el de mayor importe entre ellos
        -- 2. Si no hay conceptos de renta, se elige el de mayor importe general
        SELECT TOP 1 @IdConFacOriginalPrincipal = IDCONFAC
        FROM CTE_Conceptos
        ORDER BY 
            -- Prioriza los conceptos de renta (EsRenta = 1 va antes que 0)
            EsRenta DESC,
            -- Dentro del grupo prioritario, elige el de mayor importe
            IMPORTE DESC;

        RETURN @IdConFacOriginalPrincipal;
    END
GO

Grant Execute, view definition on dbo.fn_GetIdConFacOriginalUnico to public;
GO

/*
-- Tests
PRINT 'Test 1: ID 1001';
PRINT dbo.fn_GetIdConFacOriginalUnico('EB66AE6D-C29B-49F6-803B-3021609C9D22');

PRINT 'Test 2: ID 1002';
PRINT dbo.fn_GetIdConFacOriginalUnico('8F017216-3862-4585-83AB-59CB132D2D3D');

SELECT 
    cp.FacturasNumero, 
    cp.Descripcion, 
    cf.IDCONFAC, 
    cf.MTIPO,
    ResultadoFuncion = dbo.fn_GetIdConFacOriginalUnico(cp.ID)
FROM OperConFacPers AS cp
JOIN OperConFac AS cf ON cf.IDCONFAC = dbo.fn_GetIdConFacOriginalUnico(cp.ID);
*/
-- print dbo.fn_GetIdConFacOriginalUnico('03fdf62a-346a-4f33-b2b3-2ac88dc2623d')

-- Select Id, r.IDCONFAC
--     from OperConFacPers as pers
--     join rlnOperConFac_OperConFacPers as r on r.IDCONFACPERS = pers.Id
--     join OperConFac as con on con.IDCONFAC = r.IDCONFAC

-- Select * from rlnOperConFac_OperConFacPers
-- Select * from OperConFacPers
-- Update rlnOperConFac_OperConFacPers set IDCONFAC = 1083531 where IDCONFACPERS = '03fdf62a-346a-4f33-b2b3-2ac88dc2623d'
