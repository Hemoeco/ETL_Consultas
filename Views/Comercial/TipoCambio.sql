/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de tipo de cambio desde Comercial
------------------------------------------------------- */

-- Drop View If Exists [Comercial].[TipoCambio]
-- GO

Create or alter view [Comercial].[TipoCambio]
As
    SELECT *
    FROM ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio
GO

-- -- Tests
-- Select top 10 * from Comercial.TipoCambio
