/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos ordenes de trabajo por timbrar
-- en un juego reducido de datos
--
-- una vez que utlizamos sinonimos, incluimos las tablas de
-- Score y COmercial, para crear la vista más eficiente 
-- posible.
--
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
