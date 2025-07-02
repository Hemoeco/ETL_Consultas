/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos ordenes de trabajo por timbrar
-- en un juego reducido de datos
------------------------------------------------------- */

-- con sinonimos

Create or alter view [Score].[OTPorTimbrar]
As
	with FechaHoyIT as (
		-- calcular fecha IT hoy uan vez
		select dbo.fn_FechaIT(getdate()) as Hoy
	),
	OTConRefacciones AS (
		-- Pre-calculate spare parts totals to avoid correlated subquery
		SELECT 
			ORDENESTRABAJONUMERO,
			SUM(CANTIDAD - CANTIDADDEVUELTA) AS TotalRefacciones
		FROM Score.OTRefaccion
		GROUP BY ORDENESTRABAJONUMERO
		HAVING SUM(CANTIDAD - CANTIDADDEVUELTA) <> 0
	),
	OTCentOper as (
		Select NUMERO, 
			Concat('ODT', dbo.fn_StdCentOper(OT.IDCENTROOPERATIVO)) as cCodigoConcepto
		from Score.OT as OT
	)
	Select OT.NUMERO,
		dbo.fn_FechaITaETL(FECHATERMINADO) AS FechaTerminadoStr,
		CO.cCodigoConcepto,
		OT.IDSUCURSAL,
		OT.IDCENTROOPERATIVO,
		FECHATERMINADO,
		rtrim(T1.INICIALES) as Iniciales
	from Score.OT as OT
		join FechaIncluirAPartirDe as F on FECHATERMINADO >= F.FechaCorte
		join FechaHoyIT as H on FECHATERMINADO <= H.Hoy
		join OTConRefacciones AS R ON R.ORDENESTRABAJONUMERO = OT.NUMERO
		INNER JOIN Score.ParaCentOper T1 ON T1.IDCENTROOPERATIVO = OT.IDCENTROOPERATIVO
		left join OTCentOper as CO on CO.NUMERO = OT.NUMERO
		join Comercial.Concepto as con on con.CCODIGOCONCEPTO = CO.cCodigoConcepto
	WHERE FACTURASNUMERO = 0
		and not exists (Select 1 
						from Comercial.Documento as doc
						where doc.CIDCONCEPTODOCUMENTO = con.CIDCONCEPTODOCUMENTO AND doc.cFolio = OT.NUMERO) -- AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES)
GO

-- test
-- Select * from [Score].[OTPorTimbrar]
-- Select count(1) from [Score].[OTPorTimbrar]
go

/* Con servidor.bd.schema.tabla
--Create or alter view [Score].[OTPorTimbrar]
--As
--	with FechaHoyIT as (
--		-- calcular fecha IT hoy uan vez
--		select dbo.fn_FechaIT(getdate()) as Hoy
--	),
--	OTConRefacciones AS (
--		-- Pre-calculate spare parts totals to avoid correlated subquery
--		SELECT 
--			ORDENESTRABAJONUMERO,
--			SUM(CANTIDAD - CANTIDADDEVUELTA) AS TotalRefacciones
--		FROM serverScore.IT_Rentas_pruebas.dbo.OperOTRefacciones
--		GROUP BY ORDENESTRABAJONUMERO
--		HAVING SUM(CANTIDAD - CANTIDADDEVUELTA) <> 0
--	),
--	OTCentOper as (
--		Select NUMERO, 
--			Concat('ODT', dbo.fn_StdCentOper(OT.IDCENTROOPERATIVO)) as cCodigoConcepto
--		from serverScore.IT_Rentas_pruebas.dbo.OperOrdenesTrabajo as OT
--	)
--	Select OT.NUMERO,
--		dbo.fn_FechaITaETL(FECHATERMINADO) AS FechaTerminadoStr,
--		CO.cCodigoConcepto,
--		OT.IDSUCURSAL,
--		IDCENTROOPERATIVO,
--		FECHATERMINADO
--	from serverScore.IT_Rentas_pruebas.dbo.OperOrdenesTrabajo as OT
--		join FechaIncluirAPartirDe as F on FECHATERMINADO >= F.FechaCorte
--		join FechaHoyIT as H on FECHATERMINADO <= H.Hoy
--		join OTConRefacciones AS R ON R.ORDENESTRABAJONUMERO = OT.NUMERO
--		left join OTCentOper as CO on CO.NUMERO = OT.NUMERO
--	WHERE FACTURASNUMERO = 0
--		and not exists (Select 1 
--						from adHEMOECO_prueba.dbo.admDocumentos as doc
--							join adHEMOECO_prueba.dbo.admConceptos as con on con.CCODIGOCONCEPTO = CO.cCodigoConcepto
--						where doc.CIDCONCEPTODOCUMENTO = con.CIDCONCEPTODOCUMENTO AND doc.cFolio = OT.NUMERO) -- AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES)

--go

---- test
--Select count(1) from [Score].[OTPorTimbrar]
*/

/* ----------------------------------------------------
    Opcion alternativa con 'join', resulto un poco más
    eficiente la anterior, con 'not exists'

-- Create or alter view [Score].[OTPorTimbrar]
-- As
-- 	with FechaHoyIT as (
-- 		-- calcular fecha IT hoy uan vez
-- 		select dbo.fn_FechaIT(getdate()) as Hoy
-- 	),
-- 	OTConRefacciones AS (
-- 		-- Pre-calculate spare parts totals to avoid correlated subquery
-- 		SELECT 
-- 			ORDENESTRABAJONUMERO,
-- 			SUM(CANTIDAD - CANTIDADDEVUELTA) AS TotalRefacciones
-- 		FROM Score.OTRefaccion
-- 		GROUP BY ORDENESTRABAJONUMERO
-- 		HAVING SUM(CANTIDAD - CANTIDADDEVUELTA) <> 0
-- 	),
-- 	OTCentOper as (
-- 		Select NUMERO, 
-- 			Concat('ODT', dbo.fn_StdCentOper(OT.IDCENTROOPERATIVO)) as cCodigoConcepto
-- 		from Score.OT
-- 	)
-- 	Select OT.*,
-- 	dbo.fn_FechaITaETL(FECHATERMINADO) AS FechaTerminadoStr,
-- 	CO.cCodigoConcepto
-- 	from Score.OT
-- 		join FechaIncluirAPartirDe as F on FECHATERMINADO >= F.FechaCorte
-- 		join FechaHoyIT as H on FECHATERMINADO <= H.Hoy
-- 		join OTConRefacciones AS R ON R.ORDENESTRABAJONUMERO = OT.NUMERO
-- 		left join OTCentOper as CO on CO.NUMERO = OT.NUMERO
-- 		left join Comercial.Concepto as T2 on T2.CCODIGOCONCEPTO = CO.cCodigoConcepto
-- 		left join Comercial.Documento as T3 on T3.CIDCONCEPTODOCUMENTO = T2.CIDCONCEPTODOCUMENTO
-- 					AND T3.cFolio = OT.NUMERO -- AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES) 
-- 	WHERE FACTURASNUMERO = 0
-- 		and T3.cFolio is null
    */