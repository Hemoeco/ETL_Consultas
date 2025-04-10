-- ***********************************************************
-- (c) 2021 Hemoeco
--
-- Auxiliar para convertir una fecha al valor entero equivalente
-- utilizado en IT
--
-- ***********************************************************

if exists (select *
            from   sys.objects
            where  object_id = OBJECT_ID(N'[dbo].[fn_FechaIT]')
            AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
    drop function [dbo].[fn_FechaIT]
go

Create function [dbo].[fn_FechaIT]
(	
	@Fecha date
)
Returns int 
WITH SCHEMABINDING
As
    Begin
        Return (Select DateDiff(day, '1800-12-28', @Fecha))
    End
go

Grant Execute, view definition on dbo.fn_FechaIT to public;