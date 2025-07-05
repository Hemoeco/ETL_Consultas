/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos ordenes de trabajo por timbrar
-- en un juego reducido de datos
------------------------------------------------------- */

-- Drop view [Score].[RMPorTimbrar]

Create or alter view [Score].[RMPorTimbrar]
As
	-- Al utilizar este CTE, la consulta tarda demasiado. el join a 'Comercial.Concepto T3' funciona rápidamente
	-- sólo con la fórmula desarrollada en la condición "join on"
	--with RMCentOper as (
	--	Select IDRECEPCIONMERCANCIA, 
	--		Concat('FACP' + dbo.fn_StdCentOper(RM.IDCENTROOPERATIVO), IIF(RM.MONEDA like 'P%', 'N', 'E')) as cCodigoConcepto
	--	from serverScore.IT_Rentas_Pruebas.dbo.OperRecepcionMercancia as RM
	--),
	With NumConceptoFolio as (
		select doc.CIDCONCEPTODOCUMENTO, doc.CFOLIO, count(*) as Num 
			from Comercial.Documento as doc 
			group by doc.CIDCONCEPTODOCUMENTO, doc.CFOLIO)
	Select RM.IDRECEPCIONMERCANCIA,
		dbo.fn_FechaITaETL(FECHADOCUMENTO) as FechaDocumentoStr,
		FECHADOCUMENTO,
		RM.IDPROVEEDOR,
		T5.INICIALES,
		RM.MONEDA,
		Coalesce(T9.TipoCambio, RM.TIPOCAMBIO)  AS TipoCambio,
		NUMERODOCUMENTO,
		RM.IDSUCURSAL,
		RM.IDCENTROOPERATIVO,
		PORCENTAJEIVA,
		T3.CCODIGOCONCEPTO,
		T3.cIdConceptoDocumento,
		D.Num,
		T10.UUID
	from Score.RM as RM
		join FechaIncluirAPartirDe as F on FECHARECEPCION >= F.FechaCorte
		INNER JOIN Score.Proveedor T2 ON RM.IDPROVEEDOR = T2.IDPROVEEDOR
		INNER JOIN Score.ParaPreferencias T4 ON T4.IDPREFERENCIAS = 1
		INNER JOIN Score.ParaCentOper T5 ON RM.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
		-- join RMCentOper as CO on CO.IDRECEPCIONMERCANCIA = RM.IDRECEPCIONMERCANCIA -- ¡Muy lento!
		-- left JOIN Comercial.Concepto T3 ON T3.CCODIGOCONCEPTO = CO.cCodigoConcepto -- ¡Muy lento!
		INNER JOIN Comercial.Concepto T3 ON T3.CCODIGOCONCEPTO = Concat('FACP', dbo.fn_StdCentOper(RM.IDCENTROOPERATIVO), IIF(RM.MONEDA like 'P%', 'N', 'E'))
		left JOIN NumConceptoFolio as D on D.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO AND D.CFOLIO = RM.IDRECEPCIONMERCANCIA
		LEFT JOIN Comercial.TipoCambio AS T9 ON T9.Moneda = 2 AND T9.Tipo = 1 AND T9.Fecha = dbo.Fecha(RM.FECHADOCUMENTO)
		LEFT JOIN Comercial.Comprobante T10 on left(T10.TipoComprobante,1)='I' and rtrim(T10.RFCEmisor) = rtrim(T2.RFC) and T10.Serie + T10.Folio = RM.NUMERODOCUMENTO
	where Cerrada = 1
		AND RM.Estado = 'Contabilizada'
		and RM.IDRECEPCIONMERCANCIA > 36081
		and RM.IDRECEPCIONMERCANCIA not in (40384, 40639)
		and RM.Tipo NOT IN ('Consignación')
		and not exists (Select 1 
						from Comercial.Documento T1 with(nolock) 
						Where T1.CCANCELADO=0 
							and T1.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO 
							AND T1.CFOLIO = RM.IDRECEPCIONMERCANCIA)
		-- and 0 = 1 -- Solo pruebas
GO

-- test
-- Select * from [Score].[RMPorTimbrar]
