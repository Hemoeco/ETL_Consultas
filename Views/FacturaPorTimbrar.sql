/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener las facturas por timbrar
 ---------------------------------------------------- */

--drop view if exists [Score].[FacturaPorTimbrar]
--GO

Create or alter view [Score].[FacturaPorTimbrar]
As
    SELECT *
    FROM Score.Factura
    WHERE TOTAL <> 0
        AND CANCELADA = 'N'
        AND FOLIO2 = ''
        AND PROCESADA = 'N'
        --  AND ISNULL(T4.FORMADEPAGO,'')<>''
        AND FECHA >= 80723 -- 2022-01-01 00:00:00.000
        --  AND (datediff(dd, dbo.Fecha(FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(FECHA), GETDATE()) = 0 AND PROCESADA = 'N')) -- Condicion para que Timbre Facturas al final del dia Sin Checkbox Timbrar
GO

-- Tests
-- Select top 10 * from Score.FacturaPorTimbrar