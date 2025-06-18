-- ***********************************************************
-- (c) 2025 Hemoeco
--
-- Auxiliar para obtener la primer palabra de un string,
-- desde el inicio hasta el primer espacio, Si no hay espacio,
-- regresa la palabra completa
-- ***********************************************************

Create or alter function [dbo].[fn_PrimerPalabra] (
    @descripcion varchar(1000)
)
returns varchar(1000)
AS
Begin
    -- Obtiene la primer palabra hasta el primer espacio
    RETURN SUBSTRING(@descripcion, 1, CHARINDEX(' ', @descripcion + ' ') - 1);
End

GO

Grant Execute, view definition on dbo.fn_PrimerPalabra to public;

 -- test
-- print dbo.fn_PrimerPalabra('Reparacion de máquina'); -- Reparacion
-- print dbo.fn_PrimerPalabra('Renta de plataforma'); -- Renta
-- print dbo.fn_PrimerPalabra('Servicio a obra'); -- Servicio
-- print dbo.fn_PrimerPalabra('Otro'); -- Otro
