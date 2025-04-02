GO
Alter view [dbo].[CancelaDocumentos] as
select K.cCodigoConcepto, FD.CSERIE as cSerieDocumento, FD.cFolio, T0.ClaveMotivo as Motivo
FROM [192.168.111.14].IT_Rentas_Pruebas.dbo.OperFacSolicitudCancelacion T0
	inner join [192.168.111.14].IT_Rentas_Pruebas.dbo.OperFacturas T1 on T0.FacturasNumero = T1.IDFACTURA
	inner join adhemoeco_prueba.dbo.admFoliosDigitales FD on FD.CESTADO in (2, 5) and convert(varchar(100), FD.CUUID) = convert(varchar(100), T1.SAT_UUID)
	inner join adhemoeco_prueba.dbo.admConceptos K on K.CIDCONCEPTODOCUMENTO = FD.CIDCPTODOC
where 0=1 -- Cesar. Do not cancel anything for now.
union select K.cCodigoConcepto, D.CSERIEDOCUMENTO, D.CFOLIO, null as Motivo
FROM [192.168.111.14].IT_Rentas_Pruebas.dbo.OperRecepcionMercancia T0
	INNER JOIN adhemoeco_prueba.dbo.admConceptos K ON K.CCODIGOCONCEPTO = 'FACP' + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END
	inner JOIN adhemoeco_prueba.dbo.admDocumentos D ON D.CCANCELADO=0 and D.CIDCONCEPTODOCUMENTO = K.CIDCONCEPTODOCUMENTO AND D.CFOLIO = T0.IDRECEPCIONMERCANCIA
where T0.Estado='Cancelada' 
    and 0=1 -- Cesar. Do not cancel anything for now.

GO
