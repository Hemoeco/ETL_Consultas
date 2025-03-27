/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de cliente y cliente sucursal
-- desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[Cliente]
-- GO

Create or alter view [Score].[Cliente]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.CataClientes
GO

Create or alter view [Score].[ClienteSucursal]
As
    SELECT *
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.CataClientesSucursal
GO

-- -- Tests
-- Select top 10 * from Score.Cliente
-- Select top 10 * from Score.ClienteSucursal