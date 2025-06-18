-- ***********************************************************
-- (c) 2021 Hemoeco
--
-- Auxiliar para convertir una fecha en valor entero de IT
-- a la fecha que necesita ETL, formato mm/dd/aaaa
--
-- ***********************************************************
Create or alter function [dbo].[fn_FechaITaETL]
(	
	@FechaIT int
)
Returns varchar(10)
As
    Begin
        Return CONVERT(VARCHAR(10), dbo.Fecha(@FechaIT), 101)
    End
go

Grant Execute, view definition on dbo.fn_FechaITaETL to public;