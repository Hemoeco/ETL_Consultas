/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Este script crea los esquemas para facilitar el uso de
-- las BD de Score y Comericial, de manera que se utilize
-- una notación estándarizada en las vistas finales, y se
-- mantenga la compatibilidad entre producción y desarrollo.
 ---------------------------------------------------- */

-- print schema_id('Score')
if schema_id('Score') is null
begin
   execute('Create schema [Score] authorization dbo')
end
go

if schema_id('Comercial') is null
begin
   execute('Create schema [Comercial] authorization dbo')
end
go
