/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de linea y cliente sucursal
-- desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[Linea]
-- GO

Create or alter view [Score].[Linea]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.CataLineas
GO

-- -- Tests
Select top 10 * from Score.Linea
