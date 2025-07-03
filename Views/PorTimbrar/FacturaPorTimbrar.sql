/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos ordenes de factura por timbrar
------------------------------------------------------- */

Create or alter view [Score].[FacturaPorTimbrar]
As
	-- Factorizamos las notas de credito a timbrar para compartir entre
	-- documentos y movimientos
	SELECT factura.*,
		dbo.Fecha(FECHA) as FechaFactura, -- compartir esta fecha en varios puntos de movimientos
		dbo.fn_FechaITaETL(FECHA) as FechaFacturaStr -- compartir esta fecha en varios puntos de Documentos,
	-- FROM Score.Factura -- llamar a la tabla remota directamente es ligeramente má eficiente
	FROM Score.Factura as factura
		join FechaIncluirAPartirDe as F on FECHA >= F.FechaCorte
	WHERE TOTAL <> 0
		AND CANCELADA = 'N'
		AND FOLIO2 = ''
		AND PROCESADA = 'N'
		--  AND ISNULL(T4.FORMADEPAGO,'')<>''
		--  AND (datediff(dd, dbo.Fecha(FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(FECHA), GETDATE()) = 0 AND PROCESADA = 'N')) -- Condicion para que Timbre Facturas al final del dia Sin Checkbox Timbrar
	-- -- En la primer prueba las sig. facturas mostraban descr. null porque no existe el producto en Comercial.
	-- Where IDFACTURA in (466140,466141,460101,451204,449199,445635,424797,428267,428268,428489,428490,402271,404898,409615,412969,414075)
GO

-- dependiente de FacturaPorTimbrar
Create or alter view [Score].[ConFacPorTimbrar]
As
	SELECT con.*
	FROM Score.ConFac as con
		join Score.FacturaPorTimbrar as f on f.IDFACTURA = con.FACTURASNUMERO
GO

-- dependiente de FacturaPorTimbrar
Create or alter view [Score].[ConFacPersPorTimbrar]
As
	SELECT pers.*,
			-- dbo.fn_GetIdConFacOriginalUnico(pers.Id) as IdConFac  puede reemplazarse con 'IdConFacOriginal', que ahora siempre se llena
			IdConFacOriginal as IdConFac
	FROM serverScore.IT_Rentas_pruebas.dbo.OperConFacPers as pers
		join Score.FacturaPorTimbrar as f on f.IDFACTURA = pers.FacturasNumero
GO

-- -- Test
-- Select * from Score.FacturaPorTimbrar
-- Select * from Score.ConFacPorTimbrar
-- Select * from Score.ConFacPersPorTimbrar
