-- Pruebas para medir la eficiencia entre view and function.
Create or alter view FechaIncluirAPartirDe
as 
    Select dbo.fn_FechaIT(getdate()) - 360 as FechaCorte

go

Create or alter function [dbo].[fn_FechaIncluirAPartirDe] ()
returns int
AS
Begin
    -- Fecha de corte para la consulta de documentos
    -- considerar los movimientos a partir de los últimos 90 días
    RETURN dbo.fn_FechaIT(getdate()) - 190;
End

GO

Select *
from OperRecepcionMercancia
    cross join FechaIncluirAPartirDe as F
where FECHARECEPCION >= F.FechaCorte
    AND Cerrada = 1
    AND Estado = 'Contabilizada'
    and IDRECEPCIONMERCANCIA > 36081
    and IDRECEPCIONMERCANCIA not in (40384, 40639)
    and Tipo NOT IN ('Consignación')

Select *
from OperRecepcionMercancia
where FECHARECEPCION >= dbo.fn_FechaIncluirAPartirDe()
    AND Cerrada = 1
    AND Estado = 'Contabilizada'
    and IDRECEPCIONMERCANCIA > 36081
    and IDRECEPCIONMERCANCIA not in (40384, 40639)
    and Tipo NOT IN ('Consignación')
