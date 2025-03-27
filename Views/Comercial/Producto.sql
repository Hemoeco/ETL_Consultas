/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de producto desde Comercial
------------------------------------------------------- */

-- Drop View If Exists [Comercial].[Producto]
-- GO

Create or alter view [Comercial].[Producto]
As
    SELECT *
    FROM adhemoeco_prueba.dbo.admProductos
GO

-- -- Tests
-- Select top 10 * from Comercial.Producto
