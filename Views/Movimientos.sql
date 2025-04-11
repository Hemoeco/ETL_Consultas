CREATE OR ALTER VIEW [dbo].[Movimientos] AS
with CantidadConFac as (
        -- Convertir cCodigoProducto. Conversion Score
        Select IDCONFAC,
            case 
                when con.MTIPO = 'Renta equipo' then
                    case XML_ETIQUETA2 
                        when 'RENMES.' then 1 -- Caso específico de convertir cualquier cantidad de dias a 1 mes.
                        else con.DIAS 
                    end
                when con.DIAS<>0 and con.DELAL <> 'OTROS' then con.DIAS
                else con.CANTIDAD
            end AS unidadesCapturadas,
            case
                when MTIPO = 'Renta equipo' and XML_ETIQUETA2 = 'RENMES.' then (con.DIAS * con.PRECIOUNITARIO)
                else con.PRECIOUNITARIO
            end AS precio,
			CASE
				-- Conversiones especiales
				WHEN f.XML_ETIQUETA2 = 'MANIOBRA' AND MTIPO = 'servicio a obra' THEN f.XML_ETIQUETA2 -- Conversión especial para 'MANIOBRA'
				when f.XML_ETIQUETA2 <> 'MANIOBRA' AND f.XML_ETIQUETA2 is not null and f.XML_ETIQUETA2 <> ''  and MTIPO = 'Renta equipo' then f.XML_ETIQUETA2 -- Conversion Score
				--

				WHEN con.IDEQUIPONUEVO + con.IDEQUIPOUSADO <> 0 or rtrim(con.DELAL)='Arrendadora' THEN 'MOD' + convert(varchar,con.IDLINEA)
				WHEN con.IDREFACCION <> 0 THEN 'REF' + convert(varchar,con.IDREFACCION)
				WHEN MTIPO = 'Anticipo' then 'ANT'
				WHEN MTIPO = 'Renta Equipo' then 'REN'
				ELSE 'SRV'
			END AS codigoProducto
            from [192.168.111.14].IT_Rentas.dbo.OperConFac as con
                join [192.168.111.14].IT_Rentas.dbo.OperFacturas as f on f.IDFACTURA = con.FACTURASNUMERO
)
SELECT CONCAT('FAC', T0.FACTURASNUMERO) AS cIdDocumento,
	ccf.codigoProducto AS cCodigoProducto,
	ccf.unidadesCapturadas AS cUnidadesCapturadas,
	ccf.precio AS cPrecioCapturado,
	convert(decimal(15,4), ccf.unidadesCapturadas * (T1.PORCENTAJEIVA/100) * ccf.precio) AS cImpuesto1,
	T1.PORCENTAJEIVA AS cPorcentajeImpuesto1,
	0 as cPorcentajeRetencion1,
	0 as cPorcentajeRetencion2,
	'0' + convert(varchar,T1.IDSUCURSAL) +
		case when T0.IDEQUIPONUEVO <> 0 or rtrim(T0.DELAL)='Arrendadora' then 'ENUE'
			else case when T0.IDREFACCION <> 0 then 'REFA'
				else case when T0.IDEQUIPOUSADO <> 0 then 'EUSA'
				    else case when MTIPO = 'Anticipo' then 'ANT'
					    else CASE WHEN MTIPO = 'Renta Equipo' then 'EREN' else 'OTR' end
				end
			end
		  end
		end AS cCodigoAlmacen,
	rtrim(T0.DELAL) AS cReferencia, 
    dbo.fn_AdaptarDescripcionObservacion(T0.MTIPO, T0.DESCRIPCION, ccf.codigoProducto, prod.cNombreProducto)
	+ CASE WHEN isnull(T5.ADUANA,isnull(T2.ADUANA, '')) <> '' THEN ', Aduana: ' + rtrim(isnull(T5.ADUANA,isnull(T2.ADUANA,''))) + ', Pedimento Importacion: ' + rtrim(isnull(T5.PEDIMENTOIMPORTACION,isnull(T2.PEDIMENTOIMPORTACION,''))) 
    + ', Fecha Pedimento: ' + isnull(CONVERT(VARCHAR(10), dbo.fecha(isnull(T5.FECHAPEDIMENTO,T2.FECHAPEDIMENTO)), 103),'') ELSE '' END  AS cObservaMov,
--	rtrim(T0.DESCRIPCION) AS cObservaMov,
	--CASE WHEN T0.DIAS <> 0 THEN rtrim(T0.DELAL) ELSE '' END AS cTextoEx01,
	CASE 
		WHEN T1.XML_SUBTOTAL = 0 THEN ''
		WHEN T0.DIAS <> 0 THEN rtrim(SUBSTRING(T0.DELAL, 1, CHARINDEX('-', T0.DELAL))+' '+ substring(T0.DELAL, CHARINDEX('-', T0.DELAL)+1, LEN(T0.DELAL))) 
		ELSE '' 
		END AS cTextoExtra1,
	CASE 
            WHEN (T1.XML_TOTAL = 1 or T1.XML_TOTAL is null) and T4.IDEQUIPO is not null then 'Num. Int.: ' + rtrim(T4.NUMEROINTERNO) 
            else '' 
        end AS cTextoExtra2,
	convert(varchar, T0.IDCONFAC) AS cTextoExtra3,--Se agrega campo de IDCONFAC para hacer los conceptos unicos, ya que el with con union estaba identificando campos como duplicados
	case T0.DELAL 
		when 'Venta' then ISNULL(T4.COSTONACIONAL, 0) + ISNULL(T5.COSTONACIONAL, 0) + ISNULL(T2.COSTONACIONAL, 0)
		when 'Refacción' then T0.CANTIDAD * ISNULL(T3.COSTOUNITARIO, 0)
	else 0 end AS cCostoEspecifico,
	ISNULL(T5.DEPRECIACIONCONTABLEANTERIOR, 0) as cImporteExtra1,
	case T0.DELAL
		when 'Venta' then ISNULL(T4.COSTONACIONAL, 0) + ISNULL(T5.COSTONACIONAL, 0) + ISNULL(T2.COSTONACIONAL, 0)
		when 'Refacción' then T0.CANTIDAD * ISNULL(T3.COSTOUNITARIO, 0)
	else 0 end AS cImporteExtra2,
	'' as cSCMovto
FROM [192.168.111.14].IT_Rentas.dbo.OperConFac AS T0
	join CantidadConFac as ccf on ccf.IDCONFAC = T0.IDCONFAC -- Conversion Score
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.OperFacturas AS T1 ON T0.FACTURASNUMERO = T1.IDFACTURA
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposNuevos T2 ON T2.IDEQUIPO = T0.IDEQUIPONUEVO
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposRenta T4 on T4.IDEQUIPO = T0.IDEQUIPORENTA
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposUsados AS T5 ON T0.IDEQUIPOUSADO = T5.IDEQUIPO
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.OperOTRefacciones AS T3 ON T0.OTRLLAVEAUTONUMERICA = T3.IDOTREFACCIONES
	LEFT JOIN adhemoeco_prueba.dbo.admProductos AS prod ON prod.CCODIGOPRODUCTO = ccf.codigoProducto
UNION SELECT 'NC' + convert(varchar,T0.IDNOTASCREDITO) AS cIdDocumento,
	case when T0.TIPO='Anticipo' then 'ANT' else CASE WHEN T2.IDEQUIPONUEVO + T2.IDEQUIPOUSADO <> 0 THEN 'MOD' + convert(varchar, T2.IDLINEA)
		ELSE CASE WHEN T2.IDREFACCION <> 0 THEN 'REF' + convert(varchar, T2.IDREFACCION)
			 ELSE CASE WHEN MTIPO = 'Renta Equipo' then 'REN' ELSE 'SRV' END
			 END
	END END AS cCodigoProducto, 
    T0.CANTIDAD AS cUnidades,
	T0.IMPORTE / T0.CANTIDAD AS cPrecio,
	(case when T1.DESGLOSARIVA='N' then 0 else case when T1.PORCENTAJEIVA=11 then 16 else T1.PORCENTAJEIVA end /100 end) * T0.CANTIDAD * T0.IMPORTE / T0.CANTIDAD AS cImpuesto1,
	case when T1.DESGLOSARIVA='N' then 0 else case when T1.PORCENTAJEIVA=11 then 16 else T1.PORCENTAJEIVA end end AS cPorcentajeImpuesto1,
	0 as cPorcentajeRetencion1,
	0 as cPorcentajeRetencion2,
	'0' + convert(varchar,T1.IDSUCURSAL) +
		case when T2.IDEQUIPONUEVO <> 0 then 'ENUE'
			else case when T2.IDREFACCION <> 0 then 'REFA'
				else case when T2.IDEQUIPOUSADO <> 0 then 'EUSA'
					else CASE WHEN MTIPO = 'Renta Equipo' then 'EREN' else 'OTR' end
				end
			end
		end AS cCodigoAlmacen,
	--rtrim(T2.DELAL) AS cReferencia, 
	rtrim(SUBSTRING(T2.DELAL, 1, CHARINDEX('-', T2.DELAL))+' '+ substring(T2.DELAL, CHARINDEX('-', T2.DELAL)+1, LEN(T2.DELAL))) AS cReferencia, 
    case when T0.TIPO='Anticipo' then 'Anticipo' else rtrim(T2.DESCRIPCION) end AS cObservaMov,
	convert(varchar, T0.IDCONNOT) AS cTextoExtra1,
	'' AS cTextoExtra2,
	rtrim(T0.TIPO) AS cTextoExtra3,
	ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTONACIONAL, 0) + ISNULL(S4.COSTONACIONAL, 0) + T0.CANTIDAD * ISNULL(S6.COSTOUNITARIO, 0) AS cCostoEspecifico,
	(ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTONACIONAL, 0)) + ISNULL(S4.COSTONACIONAL, 0) * (isnull(S5.DEPRECIACIONCONTABLEPORCENTAJE,0) / 100) *
		CASE WHEN DATEDIFF(mm, dbo.fecha(ISNULL(S3.FECHAALTAHEMOECO, 0) + ISNULL(S4.FECHAALTARENTAHEMOECO, 0)), GETDATE()) - 1 <= 0 THEN 0
			 WHEN DATEDIFF(mm, dbo.fecha(ISNULL(S3.FECHAALTAHEMOECO, 0) + ISNULL(S4.FECHAALTARENTAHEMOECO, 0)), GETDATE()) - 1 >= S5.DEPRECIACIONCONTABLEMESES THEN 1
			ELSE (DATEDIFF(mm, dbo.fecha(ISNULL(S3.FECHAALTAHEMOECO, 0) + ISNULL(S4.FECHAALTARENTAHEMOECO, 0)), GETDATE()) - 1) / S5.DEPRECIACIONCONTABLEMESES END AS cImporteExtra1,
	ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTONACIONAL, 0) + ISNULL(S4.COSTONACIONAL, 0) + T0.CANTIDAD * ISNULL(S6.COSTOUNITARIO, 0) AS cImporteExtra2,
	'' as cSCMovto
FROM [192.168.111.14].IT_Rentas.dbo.OperConNot T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.OperNotasCredito T1 ON T0.IDNOTASCREDITO = T1.IDNOTASCREDITO
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.OperConFac T2 ON T0.IDCONFAC = T2.IDCONFAC
	LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposNuevos AS S2 ON T2.IDEQUIPONUEVO = S2.IDEQUIPO AND T2.DELAL = 'Venta'
	LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposRenta AS S3 ON T2.IDEQUIPORENTA = S3.IDEQUIPO AND T2.DELAL = 'Venta'
	LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposUsados AS S4 ON T2.IDEQUIPOUSADO = S4.IDEQUIPO AND T2.DELAL = 'Venta'
	LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataLineasSucursal AS S5 ON T2.IDLINEA = S5.IDLINEA AND T2.IDSUCURSAL = S5.IDSUCURSAL
	LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.OperOTRefacciones AS S6 ON T2.OTRLLAVEAUTONUMERICA = S6.IDOTREFACCIONES
WHERE T0.CANTIDAD > 0
  and T0.Tipo <> 'Descuento'
UNION SELECT 'REC' + rtrim(T1.IDRECEPCIONMERCANCIA) AS cIdDocumento,
	case when T0.IDREFACCION + T0.IDMODELO = 0 then '6111100002' else case when T0.IDREFACCION <> 0 then '11602' else '11601' end + REPLICATE('0', 2 - LEN(T1.IDCENTROOPERATIVO)) + CONVERT(varchar, T1.IDCENTROOPERATIVO) + '001' end AS cCodigoProducto, 
	T0.CANTIDADRECIBIDA AS cUnidades,
	T0.PRECIOUNITARIO AS cPrecio,
	--T0.CANTIDADRECIBIDA * T0.PRECIOUNITARIO / (100 + T1.PORCENTAJEIVA) AS cImpuesto1,
	convert(decimal(15,2), T0.CANTIDADRECIBIDA * T0.PRECIOUNITARIO * (T1.PORCENTAJEIVA/100)) AS cImpuesto1,
	T1.PORCENTAJEIVA AS cPorcentajeImpuesto1,
	isnull(T0.RETENCIONISR, 0) as cPorcentajeRetencion1,
	isnull(T0.RETENCIONIVA, 0) as cPorcentajeRetencion2,
	REPLICATE('0', 2 - LEN(T1.IDCENTROOPERATIVO)) + CONVERT(varchar, T1.IDCENTROOPERATIVO) + case when T0.IDREFACCION <> 0 then 'REFA' else case when T0.IDMODELO <> 0 then 'ENUE' else 'GTOS' end end AS cCodigoAlmacen,
	convert(varchar,T0.IDCONRM) AS cReferencia, 
    isnull(rtrim(T2.DESCRIPCION) + ' ' + rtrim(T2.CODIGO),'') + isnull(rtrim(T3.NOMBRE) + ' ' + rtrim(T3.MARCA) + ' ' + rtrim(T3.DESCRIPCION),'') AS cObservaMov,
	convert(varchar, isnull(T0.IDMODELO,0) + isnull(T0.IDREFACCION,0)) AS cTextoExtra1,
	'' AS cTextoExtra2,
	'' AS cTextoExtra3,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	'' as cSCMovto
from [192.168.111.14].IT_Rentas.dbo.OperConRM T0
	inner join [192.168.111.14].IT_Rentas.dbo.OperRecepcionMercancia T1 on T0.IDRECEPCIONMERCANCIA = T1.IDRECEPCIONMERCANCIA
	left join [192.168.111.14].IT_Rentas.dbo.CataRefacciones T2 on T0.IDREFACCION = T2.IDREFACCION
	left join [192.168.111.14].IT_Rentas.dbo.CataModelos T3 on T0.IDMODELO = T3.IDMODELO
where T1.FECHARECEPCION >= 80723 -- 80723 = 01/01/2022 -- year(dbo.fecha(T1.FECHARECEPCION)) >= 2022
/*UNION
SELECT 'DEV' + CONVERT(varchar, T0.IDDEVOLUCION) AS cIdDocumento,
	case when T0.IDREFACCION + T0.IDMODELO = 0 then 'SRV' else case when T0.IDREFACCION <> 0 then '11602' else '11601' end + REPLICATE('0', 2 - LEN(T1.IDCENTROOPERATIVO)) + CONVERT(varchar, T1.IDCENTROOPERATIVO) + '001' end AS cCodigoProducto, 
	T0.CANTIDAD AS cUnidades,
	S0.PRECIOUNITARIO AS cPrecio,
	convert(decimal(15,2), T0.CANTIDAD * S0.PRECIOUNITARIO * (S1.PORCENTAJEIVA/100)) AS cImpuesto1,
	S1.PORCENTAJEIVA AS cPorcent01,
	REPLICATE('0', 2 - LEN(T1.IDCENTROOPERATIVO)) + CONVERT(varchar, T1.IDCENTROOPERATIVO) + case when T0.IDREFACCION <> 0 then 'REFA' else case when T0.IDMODELO <> 0 then 'ENUE' else 'TRAN' end end AS cCodigoAlmacen,
	convert(varchar,T0.IDCONDEV) AS cReferencia, 
    isnull(rtrim(T2.DESCRIPCION) + ' ' + rtrim(T2.CODIGO),'') + isnull(rtrim(T3.NOMBRE) + ' ' + rtrim(T3.MARCA) + ' ' + rtrim(T3.DESCRIPCION),'') AS cObservaMov,
	convert(varchar, isnull(T0.IDMODELO,0) + isnull(T0.IDREFACCION,0)) AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	'' as cSCMovto
from [192.168.111.14].IT_Rentas.dbo.OperConDev T0
	inner join [192.168.111.14].IT_Rentas.dbo.OperDevoluciones T1 on T0.IDDEVOLUCION = T1.IDDEVOLUCION
	inner join [192.168.111.14].IT_Rentas.dbo.OperConRM S0 ON T0.IDCONRM = S0.IDCONRM
	inner join [192.168.111.14].IT_Rentas.dbo.OperRecepcionMercancia S1 on S0.IDRECEPCIONMERCANCIA = S1.IDRECEPCIONMERCANCIA
	left join [192.168.111.14].IT_Rentas.dbo.CataRefacciones T2 on T0.IDREFACCION = T2.IDREFACCION
	left join [192.168.111.14].IT_Rentas.dbo.CataModelos T3 on T0.IDMODELO = T3.IDMODELO
*/
UNION
SELECT 'ODT' + rtrim(T0.ORDENESTRABAJONUMERO) AS cIdDocumento,
	case when T0.IDREFACCION <> 0 then '11602' else '11601' end + REPLICATE('0', 2 - LEN(T1.IDCENTROOPERATIVO)) + CONVERT(varchar, T1.IDCENTROOPERATIVO) + '001' AS cCodigoProducto, 
	T0.CANTIDAD - T0.CANTIDADDEVUELTA AS cUnidades,
	T0.COSTOUNITARIO AS cPrecio,
	0 AS cImpuesto1,
	0 AS cPorcentajeImpuesto1,
	0 as cPorcentajeRetencion1,
	0 as cPorcentajeRetencion2,
	REPLICATE('0', 2 - LEN(T1.IDCENTROOPERATIVO)) + CONVERT(varchar, T1.IDCENTROOPERATIVO) + 'REFA' AS cCodigoAlmacen,
	convert(varchar,T0.IDOTREFACCIONES) AS cReferencia, 
    '' AS cObservaMov,
	'' AS cTextoEx0tra,
	'' AS cTextoExtra2,
	'' AS cTextoExtra3,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	'' as cSCMovto
from [192.168.111.14].IT_Rentas.dbo.OperOTRefacciones T0
	INNER JOIN [192.168.111.14].IT_Rentas.dbo.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	inner join [192.168.111.14].IT_Rentas.dbo.CataRefacciones T2 on T0.IDREFACCION = T2.IDREFACCION
where T0.CANTIDAD - T0.CANTIDADDEVUELTA <> 0
union SELECT 'REQ' + CONVERT(varchar, T0.IDREQUISICION) AS cIdDocumento,
--	case when T1.IDREFACCION + T1.IDMODELO = 0 then 'SRV' else case when T1.IDREFACCION <> 0 then '11602' else '11601' end + REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVOORIGEN)) + CONVERT(varchar, T0.IDCENTROOPERATIVOORIGEN) + '001' end AS cCodigoProducto,
	A1.CSCALMAC2 AS cCodigoProducto,
	T1.CANTIDADRECIBIDA AS cUnidades,
	ISNULL(S0.COSTONACIONAL, 0) + ISNULL(S1.COSTONACIONAL, 0) + ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTOUNITARIO, isnull(T1.COSTO, 0)) AS cPrecio,
	0 AS cImpuesto1,
	0 AS cPorcentajeImpuesto1,
	0 as cPorcentajeRetencion1,
	0 as cPorcentajeRetencion2,
	A2.CCODIGOALMACEN AS cCodigoAlmacen,
	convert(varchar,T0.IDREQUISICION) AS cReferencia, 
    '' AS cObservaMov,
	convert(varchar, T1.IDCONREQ) AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	0 as cCostoEspecifico,
	isnull(S1.COSTONACIONAL * S5.DEPRECIACIONCONTABLEPORCENTAJE / 100 *
		CASE WHEN DATEDIFF(mm, dbo.fecha(S1.FECHAALTAHEMOECO), dbo.fecha(T1.FECHARECIBIDA)) - 1 <= 0 THEN 0
			WHEN DATEDIFF(mm, dbo.fecha(S1.FECHAALTAHEMOECO), dbo.fecha(T1.FECHARECIBIDA)) - 1 >= S5.DEPRECIACIONCONTABLEMESES THEN 1
			ELSE (DATEDIFF(mm, dbo.fecha(S1.FECHAALTAHEMOECO), dbo.fecha(T1.FECHARECIBIDA)) - 1) / S5.DEPRECIACIONCONTABLEMESES END,0) AS cImporteExtra1,
	ISNULL(S0.COSTONACIONAL, 0) + ISNULL(S1.COSTONACIONAL, 0) + ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTOUNITARIO, isnull(T1.COSTO, 0)) AS cImporteExtra2,
--	A2.CSCALMAC2 as cSCMovto
	A1.CSCALMAC2 as cSCMovto
FROM [192.168.111.14].IT_Rentas.dbo.OperRequisiciones T0
	inner join [192.168.111.14].IT_Rentas.dbo.OperConReq T1 on T0.IDREQUISICION=T1.IDREQUISICION
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admAlmacenes A1 ON A1.ccodigoalmacen = REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVOORIGEN)) + CONVERT(varchar, T0.IDCENTROOPERATIVOORIGEN) + case when T1.IDREFACCION <> 0 then 'REFA' else case when T1.IDEQUIPONUEVO <> 0 then 'ENUE' else case when T1.IDEQUIPORENTA <> 0 then 'EREN' else case when T1.IDEQUIPOUSADO <> 0 then 'EUSA' else 'TRAN' end end end end
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admAlmacenes A2 ON A2.ccodigoalmacen = REPLICATE('0', 2 - LEN(T1.IDCENTROOPERATIVO)) + CONVERT(varchar, T1.IDCENTROOPERATIVO) + case when T1.IDREFACCION <> 0 then 'REFA' else case when T1.IDEQUIPONUEVO <> 0 then 'ENUE' else case when T1.IDEQUIPORENTA <> 0 then 'EREN' else case when T1.IDEQUIPOUSADO <> 0 then 'EUSA' else 'TRAN' end end end end
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposNuevos AS S0 ON T1.IDEQUIPONUEVO = S0.IDEQUIPO
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposRenta AS S1 ON T1.IDEQUIPORENTA = S1.IDEQUIPO
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposUsados AS S2 ON T1.IDEQUIPOUSADO = S2.IDEQUIPO
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.OperKardexAltas AS S3 ON T1.IDCONREQ = S3.IDCONREQ AND T1.IDREQUISICION = S3.DOCUMENTONUMERO
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataLineas S4 ON S4.IDLINEA = ISNULL(S0.IDLINEA, 0) + ISNULL(S1.IDLINEA, 0) + ISNULL(S2.IDLINEA, 0)
	LEFT JOIN [192.168.111.14].IT_Rentas.dbo.CataLineasSucursal S5 ON S4.IDLINEA = S5.IDLINEA AND T0.IDSUCURSALORIGEN = S5.IDSUCURSAL
UNION SELECT 'TR' + CONVERT(varchar, T0.IDEQUIPO) AS cIdDocumento,
	A1.CSCALMAC2 AS cCodigoProducto,
	1 AS cUnidades,
	ISNULL(T0.COSTONACIONAL, 0) AS cPrecio,
	0 AS cImpuesto1,
	0 AS cPorcentajeImpuesto1,
	0 as cPorcentajeRetencion1,
	0 as cPorcentajeRetencion2,
	A1.CCODIGOALMACEN AS cCodigoAlmacen,
	convert(varchar,T0.NUMEROINTERNO) AS cReferencia, 
    '' AS cObservaMov,
	'' AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	A2.CSCALMAC2 as cSCMovto
FROM [192.168.111.14].IT_Rentas.dbo.CataEquiposRenta T0
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admAlmacenes A1 ON A1.ccodigoalmacen = REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + 'ENUE'
	INNER JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admAlmacenes A2 ON A2.ccodigoalmacen = REPLICATE('0', 2 - LEN(T0.IDCENTROOPERATIVO)) + CONVERT(varchar, T0.IDCENTROOPERATIVO) + 'EREN'
WHERE T0.PROPIETARIO = 'Hemoeco'
GO
