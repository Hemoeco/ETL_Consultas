/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos ordenes de trabajo por timbrar
-- en un juego reducido de datos
------------------------------------------------------- */


Create or alter view [Score].[RMPorTimbrar]
As
	with RMCentOper as (
		Select IDRECEPCIONMERCANCIA, 
			Concat('FACP' + dbo.fn_StdCentOper(RM.IDCENTROOPERATIVO), IIF(RM.MONEDA like 'P%', 'N', 'E')) as cCodigoConcepto
		from serverScore.IT_Rentas_Pruebas.dbo.OperRecepcionMercancia as RM
	)
	Select RM.IDRECEPCIONMERCANCIA,
		dbo.fn_FechaITaETL(FECHADOCUMENTO) as FechaDocumentoStr,
		FECHADOCUMENTO,
		IDPROVEEDOR,
		MONEDA,
		TIPOCAMBIO,
		NUMERODOCUMENTO,
		IDSUCURSAL,
		IDCENTROOPERATIVO,
		PORCENTAJEIVA,
		CO.cCodigoConcepto,
		T3.cIdConceptoDocumento
	from serverScore.IT_Rentas_Pruebas.dbo.OperRecepcionMercancia as RM
		join FechaIncluirAPartirDe as F on FECHARECEPCION >= F.FechaCorte
		join RMCentOper as CO on CO.IDRECEPCIONMERCANCIA = RM.IDRECEPCIONMERCANCIA
		left JOIN adhemoeco_prueba.dbo.admConceptos T3 ON T3.CCODIGOCONCEPTO = CO.cCodigoConcepto
	where Cerrada = 1
		AND Estado = 'Contabilizada'
		and RM.IDRECEPCIONMERCANCIA > 36081
		and RM.IDRECEPCIONMERCANCIA not in (40384, 40639)
		and Tipo NOT IN ('Consignación')
		-- and 0 = 1 -- Solo pruebas
		and not exists (Select 1 
						from adhemoeco_prueba.dbo.admDocumentos T1 
						Where T1.CCANCELADO=0 
							and T1.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO 
							AND T1.CFOLIO = RM.IDRECEPCIONMERCANCIA)
GO

-- test
-- Select * from [Score].[RMPorTimbrar]
