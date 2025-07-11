/* ----------------------------------------------------
-- Hemoeco Renta (2025)
-- Script: Documentos.sql
-- Vista para la consulta de documentos
-- lee los documentos de Score para importarlso a Comercial
 ---------------------------------------------------- */

CREATE OR ALTER VIEW [dbo].[Documentos] AS
with FechaIncluirAPartirDe as (
	-- Fecha de corte para la consulta de documentos
	-- considerar los movimientos de los últioms 90 días
	-- se utiliza en lugar de 'dbo.FECHA(FECHA) >= 'yyyymmdd'
	select dbo.fn_FechaIT(getdate()) - 90 as Fecha
		-- , dbo.Fecha(dbo.fn_FechaIT(getdate()) - 90) as dt -- test
) -- Select * from FechaIncluirAPartirDe -- test
-- Facturas
SELECT 'FAC' + CONVERT(varchar, IDFACTURA) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHA), 101) AS cFecha,
	--CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHA + T4.DIASCREDITO), 101) AS cFechaVencimiento, 
	CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHAVENCIMIENTO), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHA), 101) AS cFechaEntregaRecepcion,
	rtrim(T06.CCODIGOCONCEPTO) AS cCodigoConcepto,
	CONVERT(varchar, CLIENTESNUMERO) AS cCodigoCteProv,
	'H' + rtrim(T1.INICIALES) AS cSerieDocumento,
--	T06.CSERIEPOROMISION as cSerieDocumento,
	0 AS cFolio,
	CASE WHEN LEFT(T0.Moneda, 1) = 'P' THEN 1 ELSE 2 END AS cIdMoneda,
	CASE WHEN (LEFT(T0.Moneda, 1) = 'P') THEN 1 ELSE isnull(T9.TipoCambio, T0.TIPOCAMBIO) END AS cTipoCambio,
	LEFT(rtrim(isnull(T2.NOMBRE, '')), 20) AS cReferencia,
	CONVERT(varchar, T0.IDFACTURA) AS cTextoExtra1,
	convert(varchar, T0.CLIENTESNUMERO) AS cTextoExtra2,
	rtrim(T4.REFERENCIA) AS cTextoExtra3,
	T0.IDSUCURSAL AS cImporteExtra1,
	rtrim(isnull(T0.OBSERVACIONES, '')) + case when T0.ORDENDECOMPRA is not null then rtrim(' ORDEN DE COMPRA:' + isnull(T0.ORDENDECOMPRA, '')) else '' end AS cObservaciones,
	convert(varchar,T0.IDEMPLEADO) AS cCodigoAgente,
--	T4.USOCFDI AS cNumeroGuia, 
	CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN isnull(T3.DIGITOSBANCOFREC,'') ELSE isnull(T3.DIGITOSBANCODOLARES,'') END AS cNumCtaPag,
--	CASE WHEN T4.METODODEPAGO = 'PPD' THEN '99' else T4.FORMADEPAGO end AS cMetodoPag,
--	CASE WHEN T4.METODODEPAGO = 'PPD' THEN 1 ELSE 0 END AS cNumParcia,
--	CASE WHEN T4.METODODEPAGO = 'PPD' THEN 2 ELSE 1 END AS cCantParci,
	T0.FORMADEPAGO as cMetodoPag,
	case when T0.METODODEPAGO='PUE' then 1 else 2 end as cCantParci,
	T0.USOCFDI as cCodConCba,
	0 as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	0 as cImporte,
	null as cUUID,
	'' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperFacturas T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataClientes T3 ON T3.IDCLIENTE = T0.CLIENTESNUMERO
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataClientesSucursal T4 ON T4.IDNUMERO = T0.CLIENTESNUMERO AND T4.IDSUCURSAL = T0.IDSUCURSAL
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos AS T06 ON T06.CCODIGOCONCEPTO = CASE WHEN T0.CLIENTESNUMERO IN (10933, 670) THEN 'PE' ELSE 'FACC' END + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END  + '40'
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataObras T2 ON T2.IDCLIENTE = T0.CLIENTESNUMERO AND T2.NUMERO = T0.OBRASNUMERO
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos AS T08 ON T08.CIDCONCEPTODOCUMENTO = T06.CIDCONCEPTODOCUMENTO AND T08.CTEXTOEXTRA1 = CONVERT(varchar, T0.IDFACTURA) COLLATE Modern_Spanish_CI_AS
	LEFT JOIN ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio AS T9 ON T9.MOneda = 2 AND T9.Tipo = 1 AND T9.Fecha = dbo.Fecha(T0.FECHA)
	join FechaIncluirAPartirDe as fc on T0.FECHA >= fc.Fecha
WHERE T0.TOTAL <> 0
  AND T0.CANCELADA = 'N'
  AND T0.FOLIO2 = ''
  AND T0.PROCESADA = 'N'
--  AND ISNULL(T4.FORMADEPAGO,'')<>''
--  AND YEAR(dbo.fecha(T0.FECHA)) >= 2022 -- ver FechaIncluirAPartirDe
--  AND (datediff(dd, dbo.Fecha(T0.FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(T0.FECHA), GETDATE()) = 0 AND T0.PROCESADA = 'N')) -- Condicion para que Timbre Facturas al final del dia Sin Checkbox Timbrar
-- Notas de credito
UNION ALL SELECT 'NC' + CONVERT(varchar, T0.IDNOTASCREDITO) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHA), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHA), 101) AS cFechaVencimiento, 
	CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHA), 101) AS cFechaEntregaRecepcion,
	rtrim(T4.CCODIGOCONCEPTO) AS cCodigoConcepto,
	CONVERT(varchar, T0.CLIENTESNUMERO) AS cCodigoCteProv,
	'N' + case when T6.TIPO='Descuento' then 'F' else '' end + rtrim(T1.INICIALES) AS cSerieDocumento,
	0 AS cFolio,
	CASE WHEN LEFT(T0.Moneda, 1) = 'P' THEN 1 ELSE 2 END AS cIdMoneda,
	CASE WHEN (LEFT(T0.Moneda, 1) = 'P') THEN 1 ELSE isnull(T9.TipoCambio, T0.TIPOCAMBIO) END AS cTipoCambio,
	LEFT(rtrim(isnull(T3.NOMBRE, '')), 20) AS cReferen01, 
	CONVERT(varchar, T0.IDNOTASCREDITO) AS cTextoEx01,
	CONVERT(varchar, T2.IDFACTURA) AS cTextoEx02,
	rtrim(T0.AUTORIZADAPOR) AS cTextoEx03,
	T0.IDSUCURSAL AS cImporteExtra1,
	rtrim(T0.CONCEPTOCREDITO) AS cObserva01, 
	convert(varchar,T2.IDEMPLEADO) AS cCodigoAgente,
	'No identificado' AS cNumCtaPag,
	T0.FORMADEPAGO AS cMetodoPag,
	1 AS cCantParci,
	'G02' as cCodConCba,
	case when T6.TIPO in ('Descuento', 'Anticipo') then T0.SUBTOTAL else 0 end as cNeto,
	case when T6.TIPO in ('Descuento', 'Anticipo') then case when T0.DESGLOSARIVA='N' then 0 else T0.PORCENTAJEIVA end else 0 end as cPorcentajeImpuesto1,
	case when T6.TIPO in ('Descuento', 'Anticipo') then T0.IVA else 0 end as cImpuesto1,
	case when T6.TIPO in ('Descuento', 'Anticipo') then T0.TOTAL else 0 end as cImporte,
	null as cUUID,
	case rtrim(T6.TIPO2)
		when 'Renta Equipo' then '4210100002'
		when 'Refacción' then '4120100002'
		when 'Otros' then '4310100002'
		when 'Venta Nuevo' then '4110100002'
		when 'Servicio a Obra' then '4310100002'
		when 'Mano de Obra' then '4310100002'
		else '' end as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperNotasCredito T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.Operfacturas T2 ON T0.IDFACTURA = T2.IDFACTURA
	INNER JOIN (select S0.IDNOTASCREDITO, max(S0.TIPO) as TIPO, count(distinct S0.TIPO) as Num, max(S1.MTIPO) as TIPO2
				from [192.168.111.14].IT_Rentas.dbo.OperConNot S0
					inner join [192.168.111.14].IT_Rentas.dbo.OperConFac S1 on S0.IDCONFAC = S1.IDCONFAC
				group by S0.IDNOTASCREDITO
				having count(distinct S0.TIPO) = 1) as T6 on T6.IDNOTASCREDITO = T0.IDNOTASCREDITO
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T4 ON T4.CCODIGOCONCEPTO = 'NC' + case when left(T6.TIPO,8)='Devoluci' then 'V' else 'F' end  + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END + '40'
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataObras T3 ON T3.IDCLIENTE = T2.CLIENTESNUMERO AND T3.NUMERO = T2.OBRASNUMERO
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos T5 ON T5.CTEXTOEXTRA1 = CONVERT(varchar, T0.IDNOTASCREDITO) AND T5.CIDCONCEPTODOCUMENTO = T4.CIDCONCEPTODOCUMENTO AND T5.cCancelado = 0
	LEFT JOIN ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio AS T9 ON T9.Moneda = 2 AND T9.Tipo = 1 AND T9.Fecha = dbo.Fecha(T0.FECHA)
	join FechaIncluirAPartirDe as fc on T0.FECHA >= fc.Fecha
WHERE T0.TOTAL <> 0
  -- AND YEAR(dbo.fecha(T0.FECHA)) >= 2024
  -- and dbo.fecha(T0.FECHA) >= '20240131' included above
  -- AND datediff(dd, dbo.Fecha(T0.FECHA), GETDATE()) <= 3
  AND T0.IDNOTASCREDITO not in ('32977')
  AND T5.CIDDOCUMENTO IS NULL
  AND T0.CERRADO = 'S'
--  and dbo.fecha(T0.FECHA) >='20220901'
UNION ALL
-- Compras y recepciones
/*
SELECT 'REC' + CONVERT(varchar, T0.IDRECEPCIONMERCANCIA) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHADOCUMENTO), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHADOCUMENTO), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), EOMONTH(dbo.Fecha(T0.FECHADOCUMENTO)), 101) AS cFechaEntregaRecepcion,
	rtrim(T3.CCODIGOCONCEPTO) AS cCodigoConcepto,
	'P' + REPLICATE('0', 5 - LEN(T0.IDPROVEEDOR)) + CONVERT(varchar, T0.IDPROVEEDOR) AS cCodigoCteProv,
	rtrim(T5.INICIALES) AS cSerieDocumento,
	T0.IDRECEPCIONMERCANCIA AS cFolio,
	CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 1 ELSE 2 END AS cIdMoneda,
	isnull(T9.TipoCambio, T0.TIPOCAMBIO)  AS cTipoCambio,
	CONVERT(varchar, T0.NUMERODOCUMENTO) AS cReferen01,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	T0.IDSUCURSAL AS cImporteExtra1,
	'Recepcion mercancia ' + CONVERT(varchar, T0.IDRECEPCIONMERCANCIA) + ', proveedor: ' + CONVERT(varchar, T0.IDPROVEEDOR) AS cObservaciones,
	'' AS cCodigoAgente,
--	'' AS cNumeroG01, 
	'' AS cNumCtaPag,
	'' AS cMetodoPag,
--	0 AS cNumParcia,
	0 AS cCantParci,
	'' as cCodConCba,
	0 as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	0 as cImporte,
	convert(varchar(50),T10.UUID) as cUUID,
	'' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperRecepcionMercancia T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataProveedores T2 ON T0.IDPROVEEDOR = T2.IDPROVEEDOR
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaPreferencias T4 ON T4.IDPREFERENCIAS = 1
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T5 ON T0.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T3 ON T3.CCODIGOCONCEPTO = 'FACP' + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos T1 ON T1.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO AND T1.cFolio = T0.IDRECEPCIONMERCANCIA
	LEFT JOIN ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio AS T9 ON T9.Moneda = 2 AND T9.Tipo = 1 AND T9.Fecha = dbo.Fecha(T0.FECHADOCUMENTO)
	LEFT JOIN [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata].dbo.Comprobante T10 on left(T10.TipoComprobante,1)='I' and rtrim(T10.RFCEmisor) = rtrim(T2.RFC) and T10.Serie + T10.Folio = T0.NUMERODOCUMENTO
WHERE year(dbo.fecha(FECHARECEPCION)) >= 2024
  AND T0.Cerrada = 1
  AND T1.cFolio IS NULL
  and dbo.fecha(T0.FECHARECEPCION) >='20241101'
  and T0.IDRECEPCIONMERCANCIA > 36081
  and T0.IDRECEPCIONMERCANCIA not in (40384, 40639)
*/
-- Cambio para volver importar RM con mismo ID y Canceladas en Comercial
SELECT 'REC' + CONVERT(varchar, T0.IDRECEPCIONMERCANCIA) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHADOCUMENTO), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHADOCUMENTO), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), EOMONTH(dbo.Fecha(T0.FECHADOCUMENTO)), 101) AS cFechaEntregaRecepcion,
	rtrim(T3.CCODIGOCONCEPTO) AS cCodigoConcepto,
	'P' + REPLICATE('0', 5 - LEN(T0.IDPROVEEDOR)) + CONVERT(varchar, T0.IDPROVEEDOR) AS cCodigoCteProv,
	case isnull(D.Num, 0) when 0 then rtrim(T5.INICIALES) else concat(rtrim(T5.INICIALES), D.Num + 1) end AS cSerieDocumento,
	T0.IDRECEPCIONMERCANCIA AS cFolio,
	CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 1 ELSE 2 END AS cIdMoneda,
	isnull(T9.TipoCambio, T0.TIPOCAMBIO)  AS cTipoCambio,
	CONVERT(varchar, T0.NUMERODOCUMENTO) AS cReferen01,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	T0.IDSUCURSAL AS cImporteExtra1,
	'Recepcion mercancia ' + CONVERT(varchar, T0.IDRECEPCIONMERCANCIA) + ', proveedor: ' + CONVERT(varchar, T0.IDPROVEEDOR) AS cObservaciones,
	'' AS cCodigoAgente,
--	'' AS cNumeroG01, 
	'' AS cNumCtaPag,
	'' AS cMetodoPag,
--	0 AS cNumParcia,
	0 AS cCantParci,
	'' as cCodConCba,
	0 as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	0 as cImporte,
	convert(varchar(50),T10.UUID) as cUUID,
	'' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperRecepcionMercancia T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataProveedores T2 ON T0.IDPROVEEDOR = T2.IDPROVEEDOR
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaPreferencias T4 ON T4.IDPREFERENCIAS = 1
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T5 ON T0.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T3 ON T3.CCODIGOCONCEPTO = 'FACP' + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END
	left JOIN (select CIDCONCEPTODOCUMENTO, CFOLIO, count(*) as Num from adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos group by CIDCONCEPTODOCUMENTO, CFOLIO) as D on D.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO AND D.CFOLIO = T0.IDRECEPCIONMERCANCIA
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos T1 ON T1.CCANCELADO=0 and T1.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO AND T1.CFOLIO = T0.IDRECEPCIONMERCANCIA
	LEFT JOIN ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio AS T9 ON T9.Moneda = 2 AND T9.Tipo = 1 AND T9.Fecha = dbo.Fecha(T0.FECHADOCUMENTO)
	LEFT JOIN [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata].dbo.Comprobante T10 on left(T10.TipoComprobante,1)='I' and rtrim(T10.RFCEmisor) = rtrim(T2.RFC) and T10.Serie + T10.Folio = T0.NUMERODOCUMENTO
	join FechaIncluirAPartirDe as fc on FECHARECEPCION >= fc.Fecha
WHERE -- year(dbo.fecha(FECHARECEPCION)) >= 2024 AND
  T0.Cerrada = 1
  AND T0.Estado = 'Contabilizada'
  -- included above and dbo.fecha(T0.FECHARECEPCION) >='20241101'
  and T0.IDRECEPCIONMERCANCIA > 36081
  and T0.IDRECEPCIONMERCANCIA not in (40384, 40639)
  and T0.Tipo NOT IN ('Consignación')
  AND T1.cFolio IS NULL
/*UNION ALL
-- Devoluciones a proveedores
SELECT 'DEV' + CONVERT(varchar, T0.IDDEVOLUCION) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHA), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHA), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHA), 101) AS cFechaEntregaRecepcion,
	rtrim(T3.CCODIGOCONCEPTO) AS cCodigoConcepto,
	'P' + REPLICATE('0', 5 - LEN(T0.IDPROVEEDOR)) + CONVERT(varchar, T0.IDPROVEEDOR) AS cCodigoCteProv,
	rtrim(T5.INICIALES) AS cSerieDocumento,
	T0.IDDEVOLUCION AS cFolio,
	CASE WHEN LEFT(T6.MONEDA, 1) = 'P' THEN 1 ELSE 2 END AS cIdMoneda,
	CASE WHEN LEFT(T6.MONEDA, 1) = 'P' THEN 1 ELSE T6.TIPOCAMBIO END AS cTipoCambio,
	CONVERT(varchar, T0.IDDEVOLUCION) AS cReferen01,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	T0.IDSUCURSAL AS cImporteExtra1,
	'Devolución ' + CONVERT(varchar, T0.IDDEVOLUCION) + ', proveedor: ' + CONVERT(varchar, T0.IDPROVEEDOR) + ', ' + rtrim(T6.TIPODOCUMENTO) + ': ' + rtrim(CONVERT(varchar, T6.NUMERODOCUMENTO)) AS cObservaciones,
	'(Ninguno)' AS cCodigoAgente,
	'' AS cNumeroG01, 
	'' AS cNumCtaPag,
	'' AS cMetodoPag,
	0 AS cNumParcia,
	0 AS cCantParci,
	0 as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	0 as cImporte,
	'' as cUUID,
	'(Ninguno)' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperDevoluciones T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataProveedores T2 ON T0.IDPROVEEDOR = T2.IDPROVEEDOR
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaPreferencias T4 ON T4.IDPREFERENCIAS = 1
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T5 ON T0.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
	inner join [192.168.111.14].IT_Rentas.dbo.OperRecepcionMercancia T6 on T6.IDRECEPCIONMERCANCIA = T0.IDRECEPCIONMERCANCIA
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T3 ON T3.CCODIGOCONCEPTO = 'NCC' + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T6.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018 .dbo.admDocumentos T1 ON T1.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO AND T1.CSERIEDOCUMENTO=rtrim(T5.INICIALES) and T1.cFolio = T0.IDDEVOLUCION
	join FechaIncluirAPartirDe as fc on FECHA >= fc.Fecha
WHERE -- year(dbo.fecha(FECHA)) >= 2019 AND 
  T1.cFolio IS NULL
  -- and dbo.fecha(T0.FECHA) >='20191001'
  and T0.IDDEVOLUCION > '477'
*/
UNION ALL
-- Ordenes de trabajo

SELECT 'ODT' + CONVERT(varchar, T0.NUMERO) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHATERMINADO), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHATERMINADO), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHATERMINADO), 101) AS cFechaEntregaRecepcion,
	rtrim(T2.CCODIGOCONCEPTO) AS cCodigoConcepto,
	'20902' AS cCodigoCteProv,
	rtrim(T1.INICIALES) AS cSerieDocumento,
	T0.NUMERO AS cFolio,
	1 AS cIdMoneda,
	1 AS cTipoCambio,
	CONVERT(varchar, T0.NUMERO) AS cReferencia,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	T0.IDSUCURSAL AS cImporteExtra1,
	'Orden de trabajo ' + CONVERT(varchar, T0.NUMERO) + ', sucursal: ' + rtrim(T1.INICIALES) AS cObservaciones,
	'(Ninguno)' AS cCodigoAgente,
--	'' AS cNumeroG01, 
	'' AS cNumCtaPag,
	'' AS cMetodoPag,
--	0 AS cNumParcia,
	0 AS cCantParci,
	'' as cCodConCba,
	0 as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	0 as cImporte,
	null as cUUID,
	'' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperOrdenesTrabajo T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T2 on T2.CCODIGOCONCEPTO = 'ODT' + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO)
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos T3 ON T3.CIDCONCEPTODOCUMENTO = T2.CIDCONCEPTODOCUMENTO AND T3.cFolio = T0.NUMERO -- AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES) 
	join FechaIncluirAPartirDe as fc on T0.FECHATERMINADO between fc.Fecha and dbo.fn_FechaIT(getdate())
WHERE -- dbo.fecha(T0.FECHATERMINADO) >= '20220101'
  -- dbo.fecha(T0.FECHATERMINADO) <= getdate() AND
  T0.FACTURASNUMERO = 0
  and (select sum(CANTIDAD - CANTIDADDEVUELTA) from [192.168.111.14].IT_Rentas.dbo.OperOTRefacciones where ORDENESTRABAJONUMERO = T0.NUMERO) <> 0
  AND T3.cFolio IS NULL
UNION ALL
-- Transpasos y requisiciones
SELECT 'REQ' + CONVERT(varchar, T0.IDREQUISICION) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.fecha(T4.FECHARECIBIDA), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.fecha(T4.FECHARECIBIDA), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), dbo.fecha(T4.FECHARECIBIDA), 101) AS cFechaEntregaRecepcion,
	rtrim(T2.CCODIGOCONCEPTO) AS cCodigoConcepto,
	'20902' AS cCodigoCteProv,
	rtrim(T1.INICIALES) AS cSerieDocumento,
	T0.IDREQUISICION AS cFolio,
	1 AS cIdMoneda,
	1 AS cTipoCambio,
	CONVERT(varchar, T0.IDREQUISICION) AS cReferencia,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	T0.IDSUCURSALORIGEN AS cImporteExtra1,
	'Requisición ' + CONVERT(varchar, T0.IDREQUISICION) + ', sucursal: ' + rtrim(T1.INICIALES) AS cObservaciones,
	'(Ninguno)' AS cCodigoAgente,
--	'' AS cNumeroG01, 
	'' AS cNumCtaPag,
	'' AS cMetodoPag,
--	0 AS cNumParcia,
	0 AS cCantParci,
	'' as cCodConCba,
	0 as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	0 as cImporte,
	null as cUUID,
	'' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperRequisiciones T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T1 ON T0.IDCENTROOPERATIVOORIGEN = T1.IDCENTROOPERATIVO
	inner join (select IDREQUISICION, FECHARECIBIDA from [192.168.111.14].IT_Rentas.dbo.OperConReq group by IDREQUISICION, FECHARECIBIDA) T4 on T0.IDREQUISICION = T4.IDREQUISICION
	inner join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T2 on T2.CCODIGOCONCEPTO = 'REQ' + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVOORIGEN)) + CONVERT(varchar, T0.IDCENTROOPERATIVOORIGEN)
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos T3 ON T3.CIDCONCEPTODOCUMENTO = T2.CIDCONCEPTODOCUMENTO AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES) AND T3.cFolio = T0.IDREQUISICION
	join FechaIncluirAPartirDe as fc on T4.FECHARECIBIDA >= fc.Fecha
WHERE -- dbo.fecha(T4.FECHARECIBIDA) >= '20220101' AND
  T3.cFolio IS NULL
  and T0.IDREQUISICION > '8492'

-- Alta en renta
UNION ALL SELECT 'TR' + CONVERT(varchar, T0.IDEQUIPO) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHAALTASUCURSAL), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHAALTASUCURSAL), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), dbo.fecha(T0.FECHAALTASUCURSAL), 101) AS cFechaEntregaRecepcion,
	rtrim(T3.CCODIGOCONCEPTO) AS cCodigoConcepto,
	'20902' AS cCodigoCteProv,
	'REN' AS cSerieDocumento,
	T0.IDEQUIPO AS cFolio,
	1 AS cIdMoneda,
	1 AS cTipoCambio,
	CONVERT(varchar, T0.NUMEROINTERNO) AS cReferencia,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	T0.IDSUCURSAL AS cImporteExtra1,
	'Alta en renta ' + CONVERT(varchar, T0.IDEQUIPO) + ', sucursal: ' + rtrim(T5.INICIALES) AS cObservaciones,
	'(Ninguno)' AS cCodigoAgente,
--	'' AS cNumeroG01, 
	'' AS cNumCtaPag,
	'' AS cMetodoPag,
--	0 AS cNumParcia,
	0 AS cCantParci,
	'' as cCodConCba,
	0 as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	0 as cImporte,
	null as cUUID,
	'' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.CataEquiposRenta T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposNuevos T1 ON T1.IDEQUIPORENTA = T0.IDEQUIPO
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataLineas T2 ON T0.IDLINEA = T2.IDLINEA
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T5 ON T0.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos T3 on T3.CIDDOCUMENTODE=2 and T3.CCODIGOCONCEPTO = 'PE' + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO)
	LEFT JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos T4 ON T4.CIDDOCUMENTODE=2 AND T4.CSERIEDOCUMENTO='REN' AND T4.CFOLIO = T0.IDEQUIPO
	join FechaIncluirAPartirDe as fc on T0.FECHAALTAHEMOECO >= fc.Fecha
WHERE -- YEAR(dbo.fecha(T0.FECHAALTAHEMOECO)) >= 2022
  -- included above and dbo.fecha(T0.FECHAALTAHEMOECO) >= '20221201' AND
  T0.PROPIETARIO = 'Hemoeco'
  and T4.CIDDOCUMENTO is null
UNION ALL
-- Pagos (Depositos)
SELECT 'D' + CONVERT(varchar, OD.IDDEPOSITO) AS cIdDocumento,
	CONVERT(VARCHAR(10), dbo.fecha(OD.FECHA), 101) AS cFecha,
	CONVERT(VARCHAR(10), dbo.fecha(OD.FECHA), 101) AS cFechaVencimiento,
	CONVERT(VARCHAR(10), dbo.fecha(OD.FECHA), 101) AS cFechaEntregaRecepcion,
	'PDC' + REPLICATE('0', 2 - LEN(OD.IDCENTROOPERATIVO)) + CONVERT(varchar, OD.IDCENTROOPERATIVO) + CASE WHEN LEFT(OD.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END + '40' AS cCodigoConcepto,
	(select top(1) convert(varchar,CLIENTESNUMERO) from [192.168.111.14].IT_Rentas.dbo.OperPagos where DEPOSITOSNUMERO = OD.IDDEPOSITO) AS cCodigoCteProv,
	'P' + rtrim(PCO.INICIALES) AS cSerieDocumento,
	OD.IDDEPOSITO AS cFolio,
	CASE WHEN LEFT(OD.Moneda, 1) = 'P' THEN 1 ELSE 2 END AS cIdMoneda,
	OD.TIPOCAMBIO AS cTipoCambio,
	convert(varchar,OD.IDDEPOSITO) AS cReferen01, 
	(SELECT value FROM fn_split_string_to_column(CCS.EMAILCOMP, ';') where column_id=1) as cTextoExtra1,
	(SELECT value FROM fn_split_string_to_column(CCS.EMAILCOMP, ';') where column_id=2) as cTextoExtra2,
	(SELECT value FROM fn_split_string_to_column(CCS.EMAILCOMP, ';') where column_id=3) as cTextoExtra3,
	CASE WHEN (LEFT(OD.Moneda, 1) = 'P') THEN 1 ELSE 1/OD.TIPOCAMBIO END * isnull(TX.IVA,0) AS cImporteExtra1,
	'' AS cObserva01, 
	'(Ninguno)' AS cCodigoAgente,
	'' AS cNumCtaPag,
	OP.IDFORMAPAGO as cMetodoPag,
	1 AS cCantParci,
	'CP01'/*'P01'*/ as cCodConCba,
	OD.IMPORTE as cNeto,
	0 as cPorcentajeImpuesto1,
	0 as cImpuesto1,
	OD.IMPORTE as cImporte,
	null as cUUID,
	rtrim(CCB.CUENTABANCARIA) as cCodigoProyecto,
	M0.CRUTACONTPAQ as cDestinatario,
	'' as cNumeroGuia
FROM [192.168.111.14].IT_Rentas.dbo.OperDepositos OD
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper PCO ON OD.IDCENTROOPERATIVO = PCO.IDCENTROOPERATIVO
	inner join [192.168.111.14].IT_Rentas.dbo.OperPagos OP on OP.DEPOSITOSNUMERO= OD.IDDEPOSITO
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.CataClientesSucursal CCS on OP.IDSUCURSAL=CCS.IDSUCURSAL and OP.CLIENTESNUMERO = CCS.IDNUMERO
	inner join [192.168.111.14].IT_Rentas.dbo.CataCuentasBancos CCB on CCB.IDCUENTABANCOS = OP.IDCUENTABANCOS
	left join (select OP.DEPOSITOSNUMERO,
					sum(case when T2.METODODEPAGO='PUE' then 1 else 0 end) as PUE,
					convert(decimal(10,2), sum(CASE WHEN (LEFT(T2.Moneda, 1) = 'P') THEN 1 ELSE T2.TIPOCAMBIO END * T2.IVA * OFP.IMPORTE/T2.TOTAL)) as IVA
				from [192.168.111.14].IT_Rentas.dbo.OperPagos OP
					inner join [192.168.111.14].IT_Rentas.dbo.OperFacPag OFP on OFP.PAGOSNUMERO = OP.NUMERO
					inner join [192.168.111.14].IT_Rentas.dbo.OperFacturas T2 on OFP.FACTURASNUMERO = T2.IDFACTURA
				where T2.TOTAL <> 0
				group by OP.DEPOSITOSNUMERO) TX on TX.DEPOSITOSNUMERO = OD.IDDEPOSITO
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admParametros M0 on M0.CIDEMPRESA>0
	left join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos M8 on M8.CIDDOCUMENTODE=9 and M8.CSERIEDOCUMENTO='P' + rtrim(PCO.INICIALES) and M8.cfolio = OD.IDDEPOSITO
	join FechaIncluirAPartirDe as fc on OD.FECHA >= fc.Fecha
where -- dbo.fecha(OD.FECHA) >='20220101'  and
 OD.TIMBRAR='S'
 and M8.CIDDOCUMENTO is null
 --AND OD.IDDEPOSITO=386326
and '10' <> case when TX.PUE>0 or OD.IMPORTE*CASE WHEN (LEFT(OD.Moneda, 1) = 'P') THEN 1 ELSE OD.TIPOCAMBIO END < 10 then '10' else 'PPD' end  -- se comenta para poder contabilizar los pagos PUE
GO

-- Tests
-- Select * from Documentos_Cesar_borrar
-- Select * from Documentos