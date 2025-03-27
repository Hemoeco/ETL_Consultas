/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de obra desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[Obra]
-- GO

Create or alter view [Score].[Obra]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.CataObras
GO

-- -- Tests
-- Select top 10 * from Score.Obra
