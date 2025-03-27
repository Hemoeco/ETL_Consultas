/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de concepto desde Comercial
------------------------------------------------------- */

-- Drop View If Exists [Comercial].[Concepto]
-- GO

Create or alter view [Comercial].[Concepto]
As
    SELECT *
    FROM adhemoeco_prueba.dbo.admConceptos
GO

-- -- Tests
-- Select top 10 * from Comercial.Concepto
