/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener refacciones desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[Refaccion]
-- GO

Create or alter view [Score].[Refaccion]
As
Select *
from [192.168.111.14].IT_Rentas_pruebas.dbo.CataRefacciones

go

-- -- tests
-- Select top 10 * from Score.Refaccion