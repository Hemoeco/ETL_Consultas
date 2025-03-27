/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de documento desde Comercial
------------------------------------------------------- */

-- Drop View If Exists [Comercial].[Documento]
-- GO

Create or alter view [Comercial].[Documento]
As
    SELECT *
    FROM adhemoeco_prueba.dbo.admDocumentos
GO

-- -- Tests
-- Select top 10 * from Comercial.Documento
