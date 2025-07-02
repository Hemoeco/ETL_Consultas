/* ----------------------------------------------------
-- Hemoeco Renta (2025)
-- Script: Documentos.sql
-- Vista para la consulta de documentos
-- lee los documentos de Score para importarlos a Comercial
 ---------------------------------------------------- */

-- clean up drop view [dbo].[Documentos]
CREATE OR ALTER VIEW [dbo].[Documentos] AS
With DocFactura
as (SELECT Concat('FAC', IDFACTURA) AS cIdDocumento,
	T0.FechaFacturaStr AS cFecha,
	--CONVERT(VARCHAR(10), dbo.Fecha(T0.FECHA + T4.DIASCREDITO), 101) AS cFechaVencimiento,
	dbo.fn_FechaITaETL(T0.FECHAVENCIMIENTO) AS cFechaVencimiento,
	T0.FechaFacturaStr AS cFechaEntregaRecepcion,
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
FROM Score.FacturaPorTimbrar T0
	INNER JOIN Score.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	INNER JOIN Score.Cliente T3 ON T3.IDCLIENTE = T0.CLIENTESNUMERO
	INNER JOIN Score.ClienteSucursal T4 ON T4.IDNUMERO = T0.CLIENTESNUMERO AND T4.IDSUCURSAL = T0.IDSUCURSAL
	INNER JOIN Comercial.Concepto AS T06 ON T06.CCODIGOCONCEPTO = CASE WHEN T0.CLIENTESNUMERO IN (10933, 670) THEN 'PE' ELSE 'FACC' END + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END  + '40'
	LEFT JOIN Score.Obra T2 ON T2.IDCLIENTE = T0.CLIENTESNUMERO AND T2.NUMERO = T0.OBRASNUMERO
	LEFT JOIN Comercial.Documento AS T08 ON T08.CIDCONCEPTODOCUMENTO = T06.CIDCONCEPTODOCUMENTO AND T08.CTEXTOEXTRA1 = CONVERT(varchar, T0.IDFACTURA) COLLATE Modern_Spanish_CI_AS
	LEFT JOIN Comercial.TipoCambio AS T9 ON T9.MOneda = 2 AND T9.Tipo = 1 AND T9.Fecha = T0.FechaFactura
), -- test Select * from DocFactura
PagosDeposito as (select OP.DEPOSITOSNUMERO,
					OP.IDFORMAPAGO, OP.IDSUCURSAL, OP.CLIENTESNUMERO, OP.IDCUENTABANCOS,
					Sum(IIf(T2.METODODEPAGO='PUE', 1, 0)) as PUE,
					Convert(decimal(10,2), Sum((IIf(T2.Moneda like 'P%', 1, T2.TIPOCAMBIO) * T2.IVA * OFP.IMPORTE)/T2.TOTAL)) as IVA
				from Score.Pago OP
					inner join Score.FacturaPago OFP on OFP.PAGOSNUMERO = OP.NUMERO
					inner join Score.Factura T2 on OFP.FACTURASNUMERO = T2.IDFACTURA
				where T2.TOTAL <> 0
				group by OP.DEPOSITOSNUMERO, OP.IDFORMAPAGO, OP.IDSUCURSAL, OP.CLIENTESNUMERO, OP.IDCUENTABANCOS),
PagoCliente AS (
	-- Claude
    SELECT DISTINCT 
        P.DEPOSITOSNUMERO,
        FIRST_VALUE(P.CLIENTESNUMERO) OVER (
            PARTITION BY P.DEPOSITOSNUMERO 
            ORDER BY P.CLIENTESNUMERO
        ) AS CLIENTESNUMERO
    FROM Score.Pago P
)
-- Facturas
SELECT * FROM DocFactura

UNION ALL
-- Notas de credito
SELECT 'NC' + CONVERT(varchar, T0.IDNOTASCREDITO) AS cIdDocumento,
	T0.FechaStr AS cFecha,
	T0.FechaStr AS cFechaVencimiento, 
	T0.FechaStr AS cFechaEntregaRecepcion,
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
FROM Score.NotaDeCreditoPorTimbrar T0
	INNER JOIN Score.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	INNER JOIN Score.Factura T2 ON T0.IDFACTURA = T2.IDFACTURA
	INNER JOIN (select S0.IDNOTASCREDITO, max(S0.TIPO) as TIPO, count(distinct S0.TIPO) as Num, max(S1.MTIPO) as TIPO2
				from Score.ConNot S0
					inner join Score.ConFac S1 on S0.IDCONFAC = S1.IDCONFAC
				group by S0.IDNOTASCREDITO
				having count(distinct S0.TIPO) = 1) as T6 on T6.IDNOTASCREDITO = T0.IDNOTASCREDITO
	INNER JOIN Comercial.Concepto T4 ON T4.CCODIGOCONCEPTO = 'NC' + case when left(T6.TIPO,8)='Devoluci' then 'V' else 'F' end  + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END + '40'
	LEFT JOIN Score.Obra T3 ON T3.IDCLIENTE = T2.CLIENTESNUMERO AND T3.NUMERO = T2.OBRASNUMERO
	LEFT JOIN Comercial.TipoCambio AS T9 ON T9.Moneda = 2 AND T9.Tipo = 1 AND T9.Fecha = dbo.Fecha(T0.FECHA)
WHERE not exists (select 1 from Comercial.Documento T5 
					Where T5.CIDCONCEPTODOCUMENTO = T4.CIDCONCEPTODOCUMENTO 
					AND  T5.CTEXTOEXTRA1 = CONVERT(varchar, T0.IDNOTASCREDITO)
					AND T5.cCancelado = 0)
	-- condiciones incluidas en 'Score.NotaDeCreditoPorTimbrar', por eficiencia
	-- AND T0.TOTAL <> 0
	-- AND T0.IDNOTASCREDITO not in ('32977')
	-- AND T0.CERRADO = 'S'
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
FROM Score.RM T0
	INNER JOIN Score.Proveedor T2 ON T0.IDPROVEEDOR = T2.IDPROVEEDOR
	INNER JOIN Score.ParaPreferencias T4 ON T4.IDPREFERENCIAS = 1
	INNER JOIN Score.ParaCentOper T5 ON T0.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
	INNER JOIN Comercial.Concepto T3 ON T3.CCODIGOCONCEPTO = 'FACP' + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T0.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END
	LEFT JOIN Comercial.Documento T1 ON T1.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO AND T1.cFolio = T0.IDRECEPCIONMERCANCIA
	LEFT JOIN Comercial.TipoCambio AS T9 ON T9.Moneda = 2 AND T9.Tipo = 1 AND T9.Fecha = dbo.Fecha(T0.FECHADOCUMENTO)
	LEFT JOIN Comercial.Comprobante T10 on left(T10.TipoComprobante,1)='I' and rtrim(T10.RFCEmisor) = rtrim(T2.RFC) and T10.Serie + T10.Folio = T0.NUMERODOCUMENTO
WHERE year(dbo.fecha(FECHARECEPCION)) >= 2024
  AND T0.Cerrada = 1
  AND T1.cFolio IS NULL
  and dbo.fecha(T0.FECHARECEPCION) >='20241101'
  and T0.IDRECEPCIONMERCANCIA > 36081
  and T0.IDRECEPCIONMERCANCIA not in (40384, 40639)
*/
-- Cambio para volver importar RM con mismo ID y Canceladas en Comercial
SELECT Concat('REC', IDRECEPCIONMERCANCIA) AS cIdDocumento,
	FechaDocumentoStr AS cFecha,
	FechaDocumentoStr AS cFechaVencimiento,
	CONVERT(VARCHAR(10), EOMONTH(dbo.Fecha(FECHADOCUMENTO)), 101) AS cFechaEntregaRecepcion, -- fn_FechaITaETL
	cCodigoConcepto,
	Concat('P', REPLICATE('0', 5 - LEN(IDPROVEEDOR)), IDPROVEEDOR) AS cCodigoCteProv,
	case isnull(Num, 0) when 0 then rtrim(INICIALES) else concat(rtrim(INICIALES), Num + 1) end AS cSerieDocumento,
	IDRECEPCIONMERCANCIA AS cFolio,
	CASE WHEN LEFT(MONEDA, 1) = 'P' THEN 1 ELSE 2 END AS cIdMoneda,
	TipoCambio AS cTipoCambio,
	CONVERT(varchar, NUMERODOCUMENTO) AS cReferen01,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	IDSUCURSAL AS cImporteExtra1,
	'Recepcion mercancia ' + CONVERT(varchar, IDRECEPCIONMERCANCIA) + ', proveedor: ' + CONVERT(varchar, IDPROVEEDOR) AS cObservaciones,
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
	convert(varchar(50),UUID) as cUUID,
	'' as cCodigoProyecto,
	'' as cDestinatario,
	'' as cNumeroGuia
FROM Score.RMPorTimbrar

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
FROM Score.Devolucion T0
	INNER JOIN Score.Proveedor T2 ON T0.IDPROVEEDOR = T2.IDPROVEEDOR
	INNER JOIN Score.ParaPreferencias T4 ON T4.IDPREFERENCIAS = 1
	INNER JOIN Score.ParaCentOper T5 ON T0.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
	inner join Score.RM T6 on T6.IDRECEPCIONMERCANCIA = T0.IDRECEPCIONMERCANCIA
	INNER JOIN Comercial.Concepto T3 ON T3.CCODIGOCONCEPTO = 'NCC' + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO) + CASE WHEN LEFT(T6.MONEDA, 1) = 'P' THEN 'N' ELSE 'E' END
	LEFT JOIN Comercial.Documento T1 ON T1.CIDCONCEPTODOCUMENTO = T3.CIDCONCEPTODOCUMENTO AND T1.CSERIEDOCUMENTO=rtrim(T5.INICIALES) and T1.cFolio = T0.IDDEVOLUCION
WHERE year(dbo.fecha(FECHA)) >= 2019
  AND T1.cFolio IS NULL
  and dbo.fecha(T0.FECHA) >='20191001'
  and T0.IDDEVOLUCION > '477'
*/
UNION ALL
-- Ordenes de trabajo
SELECT 'ODT' + CONVERT(varchar, T0.NUMERO) AS cIdDocumento,
	T0.FechaTerminadoStr AS cFecha,
	T0.FechaTerminadoStr AS cFechaVencimiento,
	T0.FechaTerminadoStr AS cFechaEntregaRecepcion,
	T0.cCodigoConcepto,
	'20902' AS cCodigoCteProv,
	T0.Iniciales AS cSerieDocumento,
	T0.NUMERO AS cFolio,
	1 AS cIdMoneda,
	1 AS cTipoCambio,
	CONVERT(varchar, T0.NUMERO) AS cReferencia,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	T0.IDSUCURSAL AS cImporteExtra1,
	'Orden de trabajo ' + CONVERT(varchar, T0.NUMERO) + ', sucursal: ' + T0.Iniciales AS cObservaciones,
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
FROM Score.OTPorTimbrar T0
-- Filtros y join incluidos en OTPorTimbrar
--  INNER JOIN Score.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
--  join Comercial.Concepto as T2 on T2.CCODIGOCONCEPTO = 'ODT' + dbo.fn_StdCentOper(OT.IDCENTROOPERATIVO)
--  left join Comercial.Documento as T3 on T3.CIDCONCEPTODOCUMENTO = T2.CIDCONCEPTODOCUMENTO
--			AND T3.cFolio = OT.NUMERO -- AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES) 
--   AND T0.FECHATERMINADO BETWEEN dbo.fn_FechaIncluirAPartirDe() and dbo.fn_FechaIT(getdate())
--   AND T0.FACTURASNUMERO = 0
--   and (select sum(CANTIDAD - CANTIDADDEVUELTA) from Score.OTRefaccion where ORDENESTRABAJONUMERO = T0.NUMERO) <> 0
--   AND T3.cFolio is null

UNION ALL

-- Transpasos y requisiciones
SELECT 'REQ' + CONVERT(varchar, T0.IDREQUISICION) AS cIdDocumento,
	T0.FechaRecibidaStr AS cFecha,
	T0.FechaRecibidaStr AS cFechaVencimiento,
	T0.FechaRecibidaStr AS cFechaEntregaRecepcion,
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
FROM Score.RequisicionPorTimbrar T0
	INNER JOIN Score.ParaCentOper T1 ON T0.IDCENTROOPERATIVOORIGEN = T1.IDCENTROOPERATIVO
	inner join Comercial.Concepto T2 on T2.CCODIGOCONCEPTO = 'REQ' + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVOORIGEN)
WHERE not exists (select 1 from Comercial.Documento T3 
					where T3.CIDCONCEPTODOCUMENTO = T2.CIDCONCEPTODOCUMENTO 
					AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES) 
					AND T3.cFolio = T0.IDREQUISICION)
  -- Incluidas en RequisicionPorTimbrar
  -- and T0.IDREQUISICION > '8492'
  -- AND T4.FECHARECIBIDA >= dbo.fn_FechaIncluirAPartirDe()
UNION ALL
-- Alta en renta
SELECT 'TR' + CONVERT(varchar, T0.IDEQUIPO) AS cIdDocumento,
	T0.FechaAltaSucursalStr AS cFecha,
	T0.FechaAltaSucursalStr AS cFechaVencimiento,
	T0.FechaAltaSucursalStr AS cFechaEntregaRecepcion,
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
FROM Score.EquipoRentaDadoDeAlta T0
	INNER JOIN Score.EquipoNuevo T1 ON T1.IDEQUIPORENTA = T0.IDEQUIPO
	INNER JOIN Score.Linea T2 ON T0.IDLINEA = T2.IDLINEA
	INNER JOIN Score.ParaCentOper T5 ON T0.IDCENTROOPERATIVO = T5.IDCENTROOPERATIVO
	INNER JOIN Comercial.Concepto T3 on T3.CIDDOCUMENTODE=2 and T3.CCODIGOCONCEPTO = 'PE' + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO)
WHERE not exists (Select 1 from Comercial.Documento T4 
					where T4.CIDDOCUMENTODE=2 AND T4.CSERIEDOCUMENTO='REN' AND T4.CFOLIO = T0.IDEQUIPO)
-- Incluido en EquipoRentaDadoDeAlta
--   AND T0.FECHAALTAHEMOECO >= dbo.fn_FechaIncluirAPartirDe()
--   AND T0.PROPIETARIO = 'Hemoeco'
UNION ALL
-- Pagos (Depositos)
-- Optimized version with performance improvements (Claude)
SELECT 
    Concat('D', OD.IDDEPOSITO) AS cIdDocumento,
    OD.FechaStr AS cFecha,
    OD.FechaStr AS cFechaVencimiento,
    OD.FechaStr AS cFechaEntregaRecepcion,
    Concat('PDC', dbo.fn_StdCentOper(OD.IDCENTROOPERATIVO), IIf(OD.MONEDA LIKE 'P%', 'N', 'E'), '40') AS cCodigoConcepto,

    convert(varchar, PC.CLIENTESNUMERO) AS cCodigoCteProv,
	-- (select top(1) convert(varchar,CLIENTESNUMERO) from Score.Pago where DEPOSITOSNUMERO = OD.IDDEPOSITO) AS cCodigoCteProv,

    'P' + rtrim(PCO.INICIALES) AS cSerieDocumento,
    OD.IDDEPOSITO AS cFolio,
    IIf(OD.Moneda LIKE 'P%', 1, 2) AS cIdMoneda,
    OD.TIPOCAMBIO AS cTipoCambio,
	convert(varchar,OD.IDDEPOSITO) AS cReferen01, 
	(SELECT value FROM fn_split_string_to_column(CCS.EMAILCOMP, ';') where column_id=1) as cTextoExtra1,
	(SELECT value FROM fn_split_string_to_column(CCS.EMAILCOMP, ';') where column_id=2) as cTextoExtra2,
	(SELECT value FROM fn_split_string_to_column(CCS.EMAILCOMP, ';') where column_id=3) as cTextoExtra3,
	CASE WHEN (LEFT(OD.Moneda, 1) = 'P') THEN 1 ELSE 1/OD.TIPOCAMBIO END * isnull(OP.IVA,0) AS cImporteExtra1,
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
FROM Score.DepositoPorTimbrar as OD with (nolock)
	INNER JOIN Score.ParaCentOper PCO with (nolock) ON OD.IDCENTROOPERATIVO = PCO.IDCENTROOPERATIVO
	-- inner join Score.Pago OP on OP.DEPOSITOSNUMERO= OD.IDDEPOSITO
	inner join PagosDeposito as OP on OP.DEPOSITOSNUMERO = OD.IDDEPOSITO
	INNER JOIN Score.ClienteSucursal as CCS with (nolock) on OP.IDSUCURSAL=CCS.IDSUCURSAL and OP.CLIENTESNUMERO = CCS.IDNUMERO
	inner join Score.CuentaBanco as CCB with (nolock) on CCB.IDCUENTABANCOS = OP.IDCUENTABANCOS
	INNER JOIN Comercial.Parametro M0 on M0.CIDEMPRESA>0
	inner join PagoCliente as PC on OP.DEPOSITOSNUMERO = PC.DEPOSITOSNUMERO
where not exists (select 1 from Comercial.Documento as M8 with (nolock) 
					where M8.CIDDOCUMENTODE=9 and M8.CSERIEDOCUMENTO='P' + rtrim(PCO.INICIALES) and M8.cfolio = OD.IDDEPOSITO)
-- Incluido en 
--  and OD.FECHA >= dbo.fn_FechaIncluirAPartirDe()
--  and OD.TIMBRAR='S'
--  --AND OD.IDDEPOSITO=386326
	and '10' <> case when OP.PUE>0 or OD.IMPORTE*CASE WHEN (LEFT(OD.Moneda, 1) = 'P') THEN 1 ELSE OD.TIPOCAMBIO END < 10 then '10' else 'PPD' end  -- se comenta para poder contabilizar los pagos PUE
GO

-- -- -- Tests
-- -- SELECT * FROM Documentos
-- -- SELECT * FROM Documentos order by cIdDocumento
-- -- Select top 10 * from Documentos
-- -- Select top 10 * from Documentos where cIdDocumento like 'FAC%'
-- -- SELECT TOP(10) * FROM admProductos WHERE cCodigoProducto LIKE 'mod%'
-- -- Select cIdDocumento from Documentos where cIdDocumento like 'ODT%'
-- -- Select top 10 * from Documentos where cIdDocumento like 'REC%'
-- --   Select top 10 * from Movimientos where cIdDocumento like 'REC%'