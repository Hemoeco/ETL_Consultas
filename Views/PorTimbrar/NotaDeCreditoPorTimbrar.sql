/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de nota de crédito por timbrar
------------------------------------------------------- */

Create or alter view [Score].[NotaDeCreditoPorTimbrar]
As
	-- Factorizamos las notas de credito a timbrar para compartir entre
	-- documentos y movimientos
	WITH ConceptosAgrupados AS (
		SELECT S0.IDNOTASCREDITO, 
			MAX(S0.TIPO) as TIPO, 
			count(distinct S0.TIPO) as Num,
			MAX(S1.MTIPO) as TIPO2
		FROM Score.ConNot S0
		INNER JOIN Score.ConFac S1 ON S0.IDCONFAC = S1.IDCONFAC
		GROUP BY S0.IDNOTASCREDITO
		HAVING COUNT(DISTINCT S0.TIPO) = 1)
	SELECT T0.IDNOTASCREDITO,
		T0.IDFACTURA,
		T0.FECHA,
		dbo.fn_FechaITaETL(FECHA) as FechaStr,
		T4.CCODIGOCONCEPTO as ComercialCodigoConcepto,
		T0.CLIENTESNUMERO,
		T6.TIPO as TipoConceptoAgrupado,
		T6.TIPO2 as Tipo2ConceptoAgrupado,
		T6.Num as NumConceptoAgrupado,
		T0.Moneda,
		T0.AUTORIZADAPOR,
		T0.IDSUCURSAL,
		T0.IDCENTROOPERATIVO,
		T0.CONCEPTOCREDITO,
		T0.FORMADEPAGO,
		T0.SUBTOTAL,
		T0.DESGLOSARIVA,
		T0.IVA,
		T0.TOTAL,
		T0.TIPOCAMBIO,
		T0.PORCENTAJEIVA
	FROM Score.NotaDeCredito as T0
		join FechaIncluirAPartirDe as F on FECHA >= F.FechaCorte
		INNER JOIN ConceptosAgrupados as T6 on T6.IDNOTASCREDITO = T0.IDNOTASCREDITO
		INNER JOIN Comercial.Concepto T4 ON T4.CCODIGOCONCEPTO = 
			Concat('NC', IIf(T6.TIPO like 'Devoluci%', 'V', 'F'), dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO), IIf(T0.MONEDA like 'P%', 'N', 'E'), '40')
	WHERE TOTAL <> 0
		AND T0.IDNOTASCREDITO <> (32977)
		AND CERRADO = 'S'
		and not exists (select 1 from Comercial.Documento T5 
							Where T5.CIDCONCEPTODOCUMENTO = T4.CIDCONCEPTODOCUMENTO 
							AND  T5.CTEXTOEXTRA1 = CONVERT(varchar, T0.IDNOTASCREDITO)
							AND T5.cCancelado = 0)
		-- AND 0 = 1 -- Solo pruebas
GO
