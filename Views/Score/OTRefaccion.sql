/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener refacciones de ordenes de trabajo desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[OTRefaccion]
-- GO

Create or alter view [Score].[OTRefaccion]
As
Select *
from [192.168.111.14].IT_Rentas_pruebas.dbo.OperOTRefacciones

go

-- -- tests
-- Select top 10 * from Score.OTRefaccion