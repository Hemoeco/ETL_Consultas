/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener parametros del centro operativo desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[ParaCentOper]
-- GO

Create or alter view [Score].[ParaCentOper]
As

Select IDCENTROOPERATIVO,
    IDSUCURSAL,
    INICIALES
from [192.168.111.14].IT_Rentas_pruebas.dbo.ParaCentOper

go

-- tests
-- Select top 10 * from Score.ParaCentOper