/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Equipo renta para importar a Comercial
------------------------------------------------------- */

Create or alter view [Score].[EquipoRentaPorImportar]
As
	SELECT T0.*,
		CONVERT(VARCHAR(10), dbo.fecha(T0.FECHAALTASUCURSAL), 101) AS FechaAltaSucursalStr
	FROM Score.EquipoRenta as T0
		join FechaIncluirAPartirDe as F on T0.FECHAALTAHEMOECO >= F.FechaCorte
	WHERE T0.PROPIETARIO = 'Hemoeco'
        and not exists (Select 1 from Comercial.Documento T4 
					where T4.CIDDOCUMENTODE=2 AND T4.CSERIEDOCUMENTO='REN' AND T4.CFOLIO = T0.IDEQUIPO)
		-- and 0 = 1 -- Solo pruebas
GO

-- Limpiar view anterior
if (Object_id('Score.EquipoRentaDadoDeAlta') is not null)
	Drop View [Score].[EquipoRentaDadoDeAlta]
