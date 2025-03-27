/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de concepto factura desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[ConFac]
-- GO

Create or alter view [Score].[ConFac]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.OperConFac
GO

-- -- Tests
-- Select top 10 * from Score.ConFac
