SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AsocCFDIs] AS
SELECT 'NC' + CONVERT(varchar, T0.IDNOTASCREDITO) AS cIdDocumento,
--	FD.cUUID,
	K.cCodigoConcepto,
	M8.cSerieDocumento,
	M8.cFolio,
	case T4.CIDDOCUMENTODE
		when 7 then case when T6.TIPO='Anticipo' then '07' else '01' end
		when 5 then case when left(T6.TIPO,8)='Devoluci' then '03' else '01' end
		else '' end as cTipoRelacion
FROM [192.168.111.14].IT_Rentas.dbo.OperNotasCredito T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.Operfacturas T2 ON T0.IDFACTURA = T2.IDFACTURA
	INNER JOIN (select S0.IDNOTASCREDITO, max(S0.TIPO) as TIPO, count(distinct S0.TIPO) as Num, max(S1.MTIPO) as TIPO2
				from [192.168.111.14].IT_Rentas.dbo.OperConNot S0
					inner join [192.168.111.14].IT_Rentas.dbo.OperConFac S1 on S0.IDCONFAC = S1.IDCONFAC
				group by S0.IDNOTASCREDITO
				having count(distinct S0.TIPO) = 1) as T6 on T6.IDNOTASCREDITO = T0.IDNOTASCREDITO
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T4 ON T4.CCODIGOCONCEPTO = 'NC' + case when T6.TIPO in ('Descuento','Anticipo') then 'F' else 'V' end  + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END + '40'
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos M8 on M8.ctextoextra1 = convert(varchar,T0.IDFACTURA) and M8.CIDDOCUMENTODE in (4, 13) and M8.CCANCELADO=0
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos K ON K.CIDCONCEPTODOCUMENTO = M8.CIDCONCEPTODOCUMENTO
	left join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admFoliosDigitales FD on FD.CIDDOCTO = M8.CIDDOCUMENTO
-- WHERE T0.IDNOTASCREDITO=32960
UNION SELECT 'FAC' + CONVERT(varchar, A0.IDFACTURA) AS cIdDocumento,
--	FD.cUUID,
	K.cCodigoConcepto,
	D.cSerieDocumento,
	D.cFolio,
	'07' as cTipoRelacion
FROM [192.168.111.14].IT_Rentas.dbo.RlnAnticiposConFac A0
	inner join [192.168.111.14].IT_Rentas.dbo.OperFacturas T0 on A0.IDFACTURAANT = T0.IDFACTURA
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos AS D ON D.CCANCELADO=0 and D.CTEXTOEXTRA1 = CONVERT(varchar, T0.IDFACTURA) COLLATE Modern_Spanish_CI_AS
	left JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos AS K ON D.CIDCONCEPTODOCUMENTO = K.CIDCONCEPTODOCUMENTO
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admFoliosDigitales AS FD ON FD.CESTADO=2 and D.CIDDOCUMENTO = FD.CIDDOCTO
GO
