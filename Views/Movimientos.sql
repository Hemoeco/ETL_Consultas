/* ----------------------------------------------------
-- Hemoeco Renta (2025)
-- Script: Documentos.sql
-- Vista para la consulta de documentos
-- lee los documentos de Score para importarlos a Comercial
------------------------------------------------------- */

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
			dbo.fn_ObtenerCodigoProducto(
				con.MTIPO,
				con.IDEQUIPONUEVO,
				con.IDEQUIPOUSADO,
				con.DELAL,
				con.IDLINEA,
				con.IDREFACCION,
				f.XML_ETIQUETA2
			) AS codigoProducto
		FROM Score.ConFac as con
			join Score.FacturaPorTimbrar as f on f.IDFACTURA = con.FACTURASNUMERO
), -- test select * from CantidadConFac,
ConFacPersCodigoProd as (
	SELECT Id, 
			dbo.fn_ConsultarCodigoProducto(Descripcion, C_ClaveProdServ, C_ClaveUnidad) AS CodigoProducto
		from Score.ConFacPersPorTimbrar as pers
),
MovConFacStd as (
	SELECT CONCAT('FAC', T0.FACTURASNUMERO) AS cIdDocumento,
		ccf.codigoProducto AS cCodigoProducto,
		ccf.unidadesCapturadas AS cUnidadesCapturadas,
		ccf.precio AS cPrecioCapturado,
		convert(decimal(15,4), ccf.unidadesCapturadas * (T1.PORCENTAJEIVA/100) * ccf.precio) AS cImpuesto1,
		T1.PORCENTAJEIVA AS cPorcentajeImpuesto1,
		0 as cPorcentajeRetencion1,
		0 as cPorcentajeRetencion2,
		dbo.fn_ObtenerCodigoAlmacen(T1.IDSUCURSAL, T0.IDEQUIPONUEVO, T0.IDEQUIPOUSADO, T0.IDREFACCION, MTIPO, T0.DELAL) AS cCodigoAlmacen,
		rtrim(T0.DELAL) AS cReferencia,
		dbo.fn_AdaptarDescripcionObservacion(T0.MTIPO, T0.DESCRIPCION, ccf.codigoProducto, prod.cNombreProducto)
		+ CASE WHEN isnull(T5.ADUANA,isnull(T2.ADUANA, '')) <> '' THEN ', Aduana: ' + rtrim(isnull(T5.ADUANA,isnull(T2.ADUANA,''))) + ', Pedimento Importacion: ' + rtrim(isnull(T5.PEDIMENTOIMPORTACION,isnull(T2.PEDIMENTOIMPORTACION,''))) 
		+ ', Fecha Pedimento: ' + isnull(CONVERT(VARCHAR(10), dbo.fecha(isnull(T5.FECHAPEDIMENTO,T2.FECHAPEDIMENTO)), 103),'') ELSE '' END  AS cObservaMov,
		CASE 
			WHEN T1.XML_SUBTOTAL = 0 THEN '' -- Conversion (temp)
			WHEN T0.DIAS <> 0 THEN rtrim(SUBSTRING(T0.DELAL, 1, CHARINDEX('-', T0.DELAL))+' '+ substring(T0.DELAL, CHARINDEX('-', T0.DELAL)+1, LEN(T0.DELAL))) 
			ELSE '' 
		END AS cTextoExtra1,
		CASE 
			WHEN (T1.XML_TOTAL = 1 or T1.XML_TOTAL is null) and T4.IDEQUIPO is not null then 'Num. Int.: ' + rtrim(T4.NUMEROINTERNO) -- Conversion (temp)
			else '' 
		end AS cTextoExtra2,
		convert(varchar, T0.IDCONFAC) AS cTextoExtra3,--Se agrega campo de IDCONFAC para hacer los conceptos unicos, ya que el with con union estaba identificando campos como duplicados
		dbo.fn_CalcularCostoEspecifico(
			T0.DELAL,
			T0.CANTIDAD,
			T3.COSTOUNITARIO,
			T2.COSTONACIONAL,
			T4.COSTONACIONAL,
			T5.COSTONACIONAL
		) AS cCostoEspecifico,
		ISNULL(T5.DEPRECIACIONCONTABLEANTERIOR, 0) as cImporteExtra1,
		dbo.fn_CalcularImporteExtra(
			T0.DELAL,           -- Tipo de operación
			T0.CANTIDAD,        -- Cantidad
			T3.COSTOUNITARIO,   -- Costo unitario refacción
			T2.COSTONACIONAL,   -- Costo nacional nuevo
			T4.COSTONACIONAL,   -- Costo nacional renta
			T5.COSTONACIONAL    -- Costo nacional usado
		) AS cImporteExtra2,
		'' as cSCMovto
	FROM Score.ConFacPorTimbrar AS T0
		join CantidadConFac as ccf on ccf.IDCONFAC = T0.IDCONFAC -- Conversion Score
		INNER JOIN Score.FacturaPorTimbrar AS T1 ON T0.FACTURASNUMERO = T1.IDFACTURA
		LEFT JOIN Score.EquipoNuevo T2 ON T2.IDEQUIPO = T0.IDEQUIPONUEVO
		LEFT JOIN Score.EquipoRenta T4 on T4.IDEQUIPO = T0.IDEQUIPORENTA
		LEFT JOIN Score.EquipoUsado AS T5 ON T0.IDEQUIPOUSADO = T5.IDEQUIPO
		LEFT JOIN Score.OTRefaccion AS T3 ON T0.OTRLLAVEAUTONUMERICA = T3.IDOTREFACCIONES	
		LEFT JOIN Comercial.Producto AS prod ON prod.CCODIGOPRODUCTO = ccf.codigoProducto
),
MovConFacPers as (
	SELECT CONCAT('FAC', pers.FacturasNumero) AS cIdDocumento,
			ccf.CodigoProducto AS cCodigoProducto,
			pers.Cantidad AS cUnidadesCapturadas,
			pers.ValorUnitario AS cPrecioCapturado,
			pers.MontoIVA AS cImpuesto1,
			f.PORCENTAJEIVA AS cPorcentajeImpuesto1,
			0 as cPorcentajeRetencion1,
			0 as cPorcentajeRetencion2,
			dbo.fn_ObtenerCodigoAlmacen(con.IDSUCURSAL, con.IDEQUIPONUEVO, con.IDEQUIPOUSADO, con.IDREFACCION, con.MTIPO, con.DELAL) AS cCodigoAlmacen,
			rtrim(pers.DelAl) AS cReferencia,
			dbo.fn_AdaptarDescripcionObservacion(con.MTIPO, pers.Descripcion, ccf.codigoProducto, prod.cNombreProducto) AS cObservaMov,
			pers.DelAl AS cTextoExtra1,
			pers.Referencia AS cTextoExtra2,
			Convert(varchar, pers.IdConFac) AS cTextoExtra3,--Se agrega campo de IDCONFAC para hacer los conceptos unicos, ya que el with con union estaba identificando campos como duplicados
			dbo.fn_CalcularCostoEspecifico(
				con.DELAL,
				con.CANTIDAD,
				ref.COSTOUNITARIO,
				eqn.COSTONACIONAL,
				eqr.COSTONACIONAL,
				equ.COSTONACIONAL
			) AS cCostoEspecifico,
			ISNULL(equ.DEPRECIACIONCONTABLEANTERIOR, 0) as cImporteExtra1,
			dbo.fn_CalcularImporteExtra(
				con.DELAL,           -- Tipo de operación
				con.CANTIDAD,        -- Cantidad
				ref.COSTOUNITARIO,   -- Costo unitario refacción
				eqn.COSTONACIONAL,   -- Costo nacional nuevo
				eqr.COSTONACIONAL,   -- Costo nacional renta
				equ.COSTONACIONAL    -- Costo nacional usado
			) AS cImporteExtra2,
			'' as cSCMovto
		from Score.ConFacPersPorTimbrar as pers
			join ConFacPersCodigoProd as ccf on ccf.Id = pers.Id
			join Score.FacturaPorTimbrar AS f ON f.IDFACTURA = pers.FacturasNumero
			join Score.ConFac as con on con.IDCONFAC = pers.IdConFac
			left join Score.EquipoNuevo AS eqn ON eqn.IDEQUIPO = con.IDEQUIPONUEVO
			left join Score.EquipoRenta AS eqr on eqr.IDEQUIPO = con.IDEQUIPORENTA
			left join Score.EquipoUsado AS equ ON equ.IDEQUIPO = con.IDEQUIPOUSADO
			left join Score.OTRefaccion AS ref ON ref.IDOTREFACCIONES = con.OTRLLAVEAUTONUMERICA
			left join Comercial.Producto AS prod ON prod.CCODIGOPRODUCTO = ccf.codigoProducto
		-- todo: Order by Ordinal
),
MovConFac as (
	 Select std.* 
	 	from MovConFacStd as std
		where not exists (Select 1 from MovConFacPers as pers where pers.cIdDocumento = std.cIdDocumento)
	Union all
	Select * from MovConFacPers
), -- Select * from MovConFac -- test
AlmacenConReq as (
	Select IDCONREQ,
			case 
				when IDREFACCION <> 0 then 'REFA' 
				when IDEQUIPONUEVO <> 0 then 'ENUE'
				when IDEQUIPORENTA <> 0 then 'EREN'
				when IDEQUIPOUSADO <> 0 then 'EUSA'
				else 'TRAN'
			end as CodigoAlmacen
	from Score.ConReq
)
-- Movimientos/Conceptos de Factura
SELECT * FROM MovConFac
UNION ALL
SELECT CONCAT('NC', T0.IDNOTASCREDITO) AS cIdDocumento,
	case 
		when T0.TIPO='Anticipo' then 'ANT'
		when MTIPO='Anticipo' then 'SRV'
		else dbo.fn_ObtenerCodigoProducto(
				MTIPO,
				T2.IDEQUIPONUEVO,
				T2.IDEQUIPOUSADO,
				T2.DELAL,
				T2.IDLINEA,
				T2.IDREFACCION,
				''
			)
	end AS cCodigoProducto,
	T0.CANTIDAD AS cUnidades,
	T0.IMPORTE / T0.CANTIDAD AS cPrecio,
	(case when T1.DESGLOSARIVA='N' then 0 else case when T1.PORCENTAJEIVA=11 then 16 else T1.PORCENTAJEIVA end /100 end) * T0.CANTIDAD * T0.IMPORTE / T0.CANTIDAD AS cImpuesto1,
	case when T1.DESGLOSARIVA='N' then 0 else case when T1.PORCENTAJEIVA=11 then 16 else T1.PORCENTAJEIVA end end AS cPorcentajeImpuesto1,
	0 as cPorcentajeRetencion1,
	0 as cPorcentajeRetencion2,
	case 
		when MTIPO='Anticipo' then Concat(dbo.fn_StdCentOper(T1.IDSUCURSAL), 'OTR')
		else dbo.fn_ObtenerCodigoAlmacen(T1.IDSUCURSAL, T2.IDEQUIPONUEVO, T2.IDEQUIPOUSADO, T2.IDREFACCION, MTIPO, '')
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
FROM Score.ConNot T0
	INNER JOIN Score.NotaDeCreditoPorTimbrar T1 ON T0.IDNOTASCREDITO = T1.IDNOTASCREDITO
	INNER JOIN Score.ConFac T2 ON T0.IDCONFAC = T2.IDCONFAC
	LEFT OUTER JOIN Score.EquipoNuevo AS S2 ON T2.IDEQUIPONUEVO = S2.IDEQUIPO AND T2.DELAL = 'Venta'
	LEFT OUTER JOIN Score.EquipoRenta AS S3 ON T2.IDEQUIPORENTA = S3.IDEQUIPO AND T2.DELAL = 'Venta'
	LEFT OUTER JOIN Score.EquipoUsado AS S4 ON T2.IDEQUIPOUSADO = S4.IDEQUIPO AND T2.DELAL = 'Venta'
	LEFT OUTER JOIN Score.LineaSucursal AS S5 ON T2.IDLINEA = S5.IDLINEA AND T2.IDSUCURSAL = S5.IDSUCURSAL
	LEFT OUTER JOIN Score.OTRefaccion AS S6 ON T2.OTRLLAVEAUTONUMERICA = S6.IDOTREFACCIONES
WHERE T0.CANTIDAD > 0
	and T0.Tipo <> 'Descuento'
UNION ALL
SELECT 'REC' + rtrim(T1.IDRECEPCIONMERCANCIA) AS cIdDocumento,
	case when T0.IDREFACCION + T0.IDMODELO = 0 then '6111100002' else case when T0.IDREFACCION <> 0 then '11602' else '11601' end + dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + '001' end AS cCodigoProducto, 
	T0.CANTIDADRECIBIDA AS cUnidades,
	T0.PRECIOUNITARIO AS cPrecio,
	--T0.CANTIDADRECIBIDA * T0.PRECIOUNITARIO / (100 + T1.PORCENTAJEIVA) AS cImpuesto1,
	convert(decimal(15,2), T0.CANTIDADRECIBIDA * T0.PRECIOUNITARIO * (T1.PORCENTAJEIVA/100)) AS cImpuesto1,
	T1.PORCENTAJEIVA AS cPorcentajeImpuesto1,
	isnull(T0.RETENCIONISR, 0) as cPorcentajeRetencion1,
	isnull(T0.RETENCIONIVA, 0) as cPorcentajeRetencion2,
	dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + case when T0.IDREFACCION <> 0 then 'REFA' else case when T0.IDMODELO <> 0 then 'ENUE' else 'GTOS' end end AS cCodigoAlmacen,
	convert(varchar,T0.IDCONRM) AS cReferencia, 
	isnull(rtrim(T2.DESCRIPCION) + ' ' + rtrim(T2.CODIGO),'') + isnull(rtrim(T3.NOMBRE) + ' ' + rtrim(T3.MARCA) + ' ' + rtrim(T3.DESCRIPCION),'') AS cObservaMov,
	convert(varchar, isnull(T0.IDMODELO,0) + isnull(T0.IDREFACCION,0)) AS cTextoExtra1,
	'' AS cTextoExtra2,
	'' AS cTextoExtra3,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	'' as cSCMovto
from Score.ConRM T0
	inner join Score.RMPorTimbrar T1 on T0.IDRECEPCIONMERCANCIA = T1.IDRECEPCIONMERCANCIA
	left join Score.Refaccion T2 on T0.IDREFACCION = T2.IDREFACCION
	left join Score.Modelo T3 on T0.IDMODELO = T3.IDMODELO
-- where T1.FECHARECEPCION >= dbo.fn_FechaIncluirAPartirDe() -- incluida en 'RMPorTimbrar'
/*UNION ALL
SELECT 'DEV' + CONVERT(varchar, T0.IDDEVOLUCION) AS cIdDocumento,
	case when T0.IDREFACCION + T0.IDMODELO = 0 then 'SRV' else case when T0.IDREFACCION <> 0 then '11602' else '11601' end + dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + '001' end AS cCodigoProducto, 
	T0.CANTIDAD AS cUnidades,
	S0.PRECIOUNITARIO AS cPrecio,
	convert(decimal(15,2), T0.CANTIDAD * S0.PRECIOUNITARIO * (S1.PORCENTAJEIVA/100)) AS cImpuesto1,
	S1.PORCENTAJEIVA AS cPorcent01,
	dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + case when T0.IDREFACCION <> 0 then 'REFA' else case when T0.IDMODELO <> 0 then 'ENUE' else 'TRAN' end end AS cCodigoAlmacen,
	convert(varchar,T0.IDCONDEV) AS cReferencia, 
	isnull(rtrim(T2.DESCRIPCION) + ' ' + rtrim(T2.CODIGO),'') + isnull(rtrim(T3.NOMBRE) + ' ' + rtrim(T3.MARCA) + ' ' + rtrim(T3.DESCRIPCION),'') AS cObservaMov,
	convert(varchar, isnull(T0.IDMODELO,0) + isnull(T0.IDREFACCION,0)) AS cTextoEx01,
	'' AS cTextoEx02,
	'' AS cTextoEx03,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	'' as cSCMovto
from Score.ConDev T0
	inner join Score.Devolucion T1 on T0.IDDEVOLUCION = T1.IDDEVOLUCION
	inner join Score.ConRM S0 ON T0.IDCONRM = S0.IDCONRM
	inner join Score.RM S1 on S0.IDRECEPCIONMERCANCIA = S1.IDRECEPCIONMERCANCIA
	left join Score.Refaccion T2 on T0.IDREFACCION = T2.IDREFACCION
	left join Score.Modelo T3 on T0.IDMODELO = T3.IDMODELO
*/
UNION ALL
SELECT 'ODT' + rtrim(T0.ORDENESTRABAJONUMERO) AS cIdDocumento,
	case when T0.IDREFACCION <> 0 then '11602' else '11601' end + dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + '001' AS cCodigoProducto, 
	T0.CANTIDAD - T0.CANTIDADDEVUELTA AS cUnidades,
	T0.COSTOUNITARIO AS cPrecio,
	0 AS cImpuesto1,
	0 AS cPorcentajeImpuesto1,
	0 as cPorcentajeRetencion1,
	0 as cPorcentajeRetencion2,
	dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + 'REFA' AS cCodigoAlmacen,
	convert(varchar,T0.IDOTREFACCIONES) AS cReferencia, 
	'' AS cObservaMov,
	'' AS cTextoEx0tra,
	'' AS cTextoExtra2,
	'' AS cTextoExtra3,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	'' as cSCMovto
from Score.OTRefaccion T0
	INNER JOIN Score.ParaCentOper T1 ON T0.IDCENTROOPERATIVO = T1.IDCENTROOPERATIVO
	inner join Score.Refaccion T2 on T0.IDREFACCION = T2.IDREFACCION
	join Score.OTPorTimbrar as OT on OT.NUMERO = T0.ORDENESTRABAJONUMERO
where T0.CANTIDAD - T0.CANTIDADDEVUELTA <> 0
	-- todo: Right filter?
	and OT.FECHATERMINADO between dbo.fn_FechaIncluirAPartirDe() and dbo.fn_FechaIT(getdate())
union all
SELECT 'REQ' + CONVERT(varchar, T0.IDREQUISICION) AS cIdDocumento,
--	case when T1.IDREFACCION + T1.IDMODELO = 0 then 'SRV' else case when T1.IDREFACCION <> 0 then '11602' else '11601' end + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVOORIGEN) + '001' end AS cCodigoProducto,
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
FROM Score.RequisicionPorTimbrar T0
	inner join Score.ConReq T1 on T0.IDREQUISICION=T1.IDREQUISICION
	inner join AlmacenConReq as alm on alm.IDCONREQ = T1.IDCONREQ
	INNER JOIN Comercial.Almacen A1 ON A1.ccodigoalmacen = dbo.fn_StdCentOper(T0.IDCENTROOPERATIVOORIGEN) + alm.CodigoAlmacen
	INNER JOIN Comercial.Almacen A2 ON A2.ccodigoalmacen = dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + alm.CodigoAlmacen
	LEFT JOIN Score.EquipoNuevo AS S0 ON T1.IDEQUIPONUEVO = S0.IDEQUIPO
	LEFT JOIN Score.EquipoRenta AS S1 ON T1.IDEQUIPORENTA = S1.IDEQUIPO
	LEFT JOIN Score.EquipoUsado AS S2 ON T1.IDEQUIPOUSADO = S2.IDEQUIPO
	LEFT JOIN Score.KardexAlta AS S3 ON T1.IDCONREQ = S3.IDCONREQ AND T1.IDREQUISICION = S3.DOCUMENTONUMERO
	LEFT JOIN Score.Linea S4 ON S4.IDLINEA = ISNULL(S0.IDLINEA, 0) + ISNULL(S1.IDLINEA, 0) + ISNULL(S2.IDLINEA, 0)
	LEFT JOIN Score.LineaSucursal S5 ON S4.IDLINEA = S5.IDLINEA AND T0.IDSUCURSALORIGEN = S5.IDSUCURSAL
	-- todo: Filter results? in Documentos, this is a subquery
	-- join FechaIncluirAPartirDe as fc on T1.FECHARECIBIDA >= fc.Fecha																	

UNION ALL

SELECT 'TR' + CONVERT(varchar, T0.IDEQUIPO) AS cIdDocumento,
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
FROM Score.EquipoRentaDadoDeAlta T0
	INNER JOIN Comercial.Almacen A1 ON A1.ccodigoalmacen = dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO) + 'ENUE'
	INNER JOIN Comercial.Almacen A2 ON A2.ccodigoalmacen = dbo.fn_StdCentOper(T0.IDCENTROOPERATIVO) + 'EREN'
GO

-- -- Tests
-- SELECT * FROM Movimientos
-- Select top 10 * from Movimientos
-- Select * from Movimientos order by cIdDocumento, cCodigoProducto, cReferencia
-- Select top 10 * from Movimientos where cIdDocumento like 'FAC%'

--Grant Execute, view definition on dbo.Fecha to public;

---------------------------------------------
-- Test  dbo.fn_AdaptarDescripcionObservacion
-- Select DescCorregida, DescrAdaptada, IIF(DescCorregida <> DescrAdaptada, 'Error', 'Exito') as compara
--   , MTIPO, DESCRIPCION, codigoProducto, cNombreProducto, IDCONFAC
--   FROM UnionMovimientos
-- Select * from Movimientos where compara <> 'exito' -- order by IDCONFAC desc 
---------------------------------------------

-- -- Test with function integrated
-- SELECT top 100 * FROM Movimientos
--    where cReferencia = 'Renta'
--    order by cIdDocumento desc
-- -- En la primer prueba las sig. facturas mostraban descr. null porque no existe el producto en Comercial.
-- where cIdDocumento in ('FAC466140','FAC466141','FAC460101','FAC451204','FAC449199','FAC445635','FAC424797','FAC428267','FAC428268','FAC428489','FAC428490','FAC402271','FAC404898','FAC409615','FAC412969','FAC414075')
--
