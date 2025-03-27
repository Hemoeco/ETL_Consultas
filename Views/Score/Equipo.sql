/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de equipo 
-- (nuevo, renta y usado) desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[EquipoNuevo]
-- GO

Create or alter view [Score].[EquipoNuevo]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.CataEquiposNuevos
GO

Create or alter view [Score].[EquipoRenta]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.CataEquiposRenta
GO

Create or alter view [Score].[EquipoUsado]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.CataEquiposUsados
GO

-- Tests
Select top 10 * from Score.EquipoNuevo
Select top 10 * from Score.EquipoRenta
Select top 10 * from Score.EquipoUsado