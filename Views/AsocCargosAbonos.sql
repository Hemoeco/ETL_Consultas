SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AsocCargosAbonos] AS
SELECT 'NC' + CONVERT(varchar, T0.IDNOTASCREDITO) AS cIdDocumento,
	M6.ccodigoconcepto AS cCodigoConcepto,
	M8.CSERIEDOCUMENTO as cSerieDocumento,
	M8.CFOLIO as cFolio,
	T0.TOTAL AS cImporte
from [192.168.111.14].IT_Rentas.dbo.OperNotasCredito T0
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos M8 on M8.ctextoextra1 = convert(varchar,T0.IDFACTURA) and M8.CIDDOCUMENTODE in (4, 13) and M8.CCANCELADO=0
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos M6 on M8.CIDCONCEPTODOCUMENTO = M6.CIDCONCEPTODOCUMENTO
UNION ALL SELECT 'D' + CONVERT(varchar, OD.IDDEPOSITO) AS cIdDocumento,
	M06.cCodigoConcepto,
	M08.cSerieDocumento,
	M08.cFolio,
	convert(decimal(10,2), case when OFP.IMPORTE-M08.cPendiente <= 0.09 and OFP.IMPORTE-M08.cPendiente>0 then M08.cPendiente else OFP.IMPORTE end / case when left(OD.MONEDA,1)=left(OI.MONEDA,1) or OD.TIPOCAMBIO=0 then 1 else case when left(OI.MONEDA,1)='P' then OP.TIPOCAMBIO else 1/OP.TIPOCAMBIO end end) AS cImporte
from [192.168.111.14].IT_Rentas.dbo.OperFacPag OFP
	inner join [192.168.111.14].IT_Rentas.dbo.OperPagos OP on OFP.PAGOSNUMERO = OP.NUMERO
	inner join [192.168.111.14].IT_Rentas.dbo.OperFacturas OI on OI.IDFACTURA = OFP.FACTURASNUMERO
	inner join [192.168.111.14].IT_Rentas.dbo.OperDepositos OD on OP.DEPOSITOSNUMERO = OD.IDDEPOSITO
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos M08 on M08.CIDDOCUMENTODE in (4,13) AND M08.CTEXTOEXTRA1 = CONVERT(varchar, OFP.FACTURASNUMERO) COLLATE Modern_Spanish_CI_AS
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos M06 on M08.CIDCONCEPTODOCUMENTO = M06.CIDCONCEPTODOCUMENTO
where M08.CCANCELADO = 0
  and M08.cPendiente > 0
UNION ALL SELECT 'P' + CONVERT(varchar, OP.NUMERO) AS cIdDocumento,
	M06.cCodigoConcepto,
	M08.cSerieDocumento,
	M08.cFolio,
	convert(decimal(10,2), case when OFP.IMPORTE-M08.cPendiente <= 0.09 and OFP.IMPORTE-M08.cPendiente>0 then M08.cPendiente else OFP.IMPORTE end / case when left(OD.MONEDA,1)='P' or OD.TIPOCAMBIO=0 then 1 else OD.TIPOCAMBIO end) AS cImporte
from [192.168.111.14].IT_Rentas.dbo.OperFacPag OFP
	inner join [192.168.111.14].IT_Rentas.dbo.OperPagos OP on OFP.PAGOSNUMERO = OP.NUMERO
	inner join [192.168.111.14].IT_Rentas.dbo.OperDepositos OD on OP.DEPOSITOSNUMERO = OD.IDDEPOSITO
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos M08 on M08.CIDDOCUMENTODE in (4,13) AND M08.CTEXTOEXTRA1 = CONVERT(varchar, OFP.FACTURASNUMERO) COLLATE Modern_Spanish_CI_AS
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos M06 on M08.CIDCONCEPTODOCUMENTO = M06.CIDCONCEPTODOCUMENTO
where M08.CCANCELADO = 0
  and M08.cPendiente > 0
GO
