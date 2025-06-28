-- ***********************************************************
-- (c) 2021 Hemoeco
--
-- Auxiliar para obtener la fecha de corte a partir de la
-- cual se obtienen los movimientos a importar.
-- Se trata de movimientos desde hace 90 días en delante
-- ***********************************************************

Create or alter function [dbo].[fn_FechaIncluirAPartirDe] ()
returns int
AS
Begin
    -- Fecha de corte para la consulta de documentos
    -- considerar los movimientos a partir de los últimos 90 días
    Declare @FechaCorte int;
    select top 1 @FechaCorte = FechaCorte from FechaIIncluirAPartirDe;
    RETURN @FechaCorte
End

GO

Grant Execute, view definition on dbo.fn_FechaIncluirAPartirDe to public;

 -- test
 -- Select dbo.fn_FechaIncluirAPartirDe(), dbo.Fecha(dbo.fn_FechaIncluirAPartirDe()) as FechaDT