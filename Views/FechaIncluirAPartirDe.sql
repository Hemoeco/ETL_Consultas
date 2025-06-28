/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener la fecha de corte a partir de la
-- cual incluir documentos (hoy menos 90 días - o 3 meses -)
------------------------------------------------------- */

Create or alter view FechaIncluirAPartirDe
as 
    Select dbo.fn_FechaIT(getdate()) - 90 as FechaCorte

go

grant select on FechaIncluirAPartirDe to PUBLIC
-- test
-- Select dbo.Fecha(FechaCorte) as FechaActual from FechaIIncluirAPartirDe