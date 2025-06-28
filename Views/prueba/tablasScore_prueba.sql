/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de cliente y cliente sucursal
-- desde Score
------------------------------------------------------- */

-- use ETL_Pruebas_Cesar
GO

-- Drop View If Exists [Score].[Cliente]
-- GO

-- Cliente y ClienteSucursal
if (Object_id('[Score].[Cliente]') is null)
	Create Synonym [Score].[Cliente] for serverScore.IT_Rentas_pruebas.dbo.CataClientes
GO

if (Object_id('[Score].[ClienteSucursal]') is null)
	Create Synonym [Score].[ClienteSucursal] for serverScore.IT_Rentas_pruebas.dbo.CataClientesSucursal
GO

if (Object_id('[Score].[ConDev]') is null)
	Create Synonym [Score].[ConDev] for serverScore.IT_Rentas_pruebas.dbo.OperConDev
GO

-- Concepto factura
if (Object_id('[Score].[ConFac]') is null)
	Create Synonym [Score].[ConFac] for serverScore.IT_Rentas_pruebas.dbo.OperConFac
GO

-- Concepto personalizado factura
-- Create or alter view [Score].[ConFacPers]
-- As
-- 	SELECT *
-- 	FROM serverScore.IT_Rentas_pruebas.dbo.OperConFacPers
-- GO

-- Concepto ndc
if (Object_id('[Score].[ConNot]') is null)
	Create Synonym [Score].[ConNot] for serverScore.IT_Rentas_pruebas.dbo.OperConNot
GO

-- concepto requisicion (ConReq)
if (Object_id('[Score].[ConReq]') is null)
	Create Synonym [Score].[ConReq] for serverScore.IT_Rentas_pruebas.dbo.OperConReq
GO

if (Object_id('[Score].[ConRM]') is null)
	Create Synonym [Score].[ConRM] for serverScore.IT_Rentas_pruebas.dbo.OperConRM
GO

-- CuentaBanco
if (Object_id('[Score].[CuentaBanco]') is null)
	Create Synonym [Score].[CuentaBanco] for serverScore.IT_Rentas_pruebas.dbo.CataCuentasBancos
GO

-- Deposito
if (Object_id('[Score].[Deposito]') is null)
	Create Synonym [Score].[Deposito] for serverScore.IT_Rentas_pruebas.dbo.OperDepositos
GO

Create or alter view [Score].[DepositoPorTimbrar]
As
	Select OD.*,
		dbo.fn_FechaITaETL(OD.FECHA) AS FechaStr
	from Score.Deposito as OD
		join FechaIncluirAPartirDe as F on OD.FECHA >= F.FechaCorte
	where OD.TIMBRAR='S'
		and OD.IDDEPOSITO > 405000 -- Solo pruebas
GO

-- Devolucion
if (Object_id('[Score].[Devolucion]') is null)
	Create Synonym [Score].[Devolucion] for serverScore.IT_Rentas_pruebas.dbo.OperDevoluciones
GO

-- Equipo (Nuevo, Renta y Usado)
if (Object_id('[Score].[EquipoNuevo]') is null)
	Create Synonym [Score].[EquipoNuevo] for serverScore.IT_Rentas_pruebas.dbo.CataEquiposNuevos
GO

if (Object_id('[Score].[EquipoRenta]') is null)
	Create Synonym [Score].[EquipoRenta] for serverScore.IT_Rentas_pruebas.dbo.CataEquiposRenta
GO

Create or alter view [Score].[EquipoRentaDadoDeAlta]
As
	SELECT T0.*,
		CONVERT(VARCHAR(10), dbo.fecha(T0.FECHAALTASUCURSAL), 101) AS FechaAltaSucursalStr
	FROM Score.EquipoRenta as T0
		join FechaIncluirAPartirDe as F on T0.FECHAALTAHEMOECO >= F.FechaCorte
	WHERE T0.PROPIETARIO = 'Hemoeco'
		-- and 0 = 1 -- Solo pruebas
GO

if (Object_id('[Score].[EquipoUsado]') is null)
	Create Synonym [Score].[EquipoUsado] for serverScore.IT_Rentas_pruebas.dbo.CataEquiposUsados
GO

-- Factura
Create or alter view [Score].[Factura]
As
	-- opcionalemente podemos utilizar 'select *'
	SELECT IDFACTURA,
		IDSUCURSAL,
		IDCENTROOPERATIVO,
		CLIENTESNUMERO,
		FOLIO,
		IDEMPLEADO,
		FECHA,
		MONEDA,
		FECHAVENCIMIENTO,
		TOTAL,
		SALDO,
		FORMADEPAGO,
		METODODEPAGO,
		USOCFDI,
		OBRASNUMERO,
		TIPOCAMBIO,
		IVA,
		CANCELADA,
		FOLIO2,
		PROCESADA,
		OBSERVACIONES,
		ORDENDECOMPRA,
		XML_ETIQUETA2,
		XML_SUBTOTAL,
		XML_TOTAL,
		PORCENTAJEIVA,
		dbo.Fecha(FECHA) as FechaFactura, -- compartir esta fecha en varios puntos de movimientos
		dbo.fn_FechaITaETL(FECHA) as FechaFacturaStr -- compartir esta fecha en varios puntos de Documentos,
	FROM serverScore.IT_Rentas_pruebas.dbo.OperFacturas
GO

-- FacturaPago
if (Object_id('[Score].[FacturaPago]') is null)
	Create synonym [Score].[FacturaPago] for serverScore.IT_Rentas_pruebas.dbo.OperFacPag
GO

Create or alter view [Score].[FacturaPorTimbrar]
As
	-- Factorizamos las notas de credito a timbrar para compartir entre
	-- documentos y movimientos
	SELECT *,
		dbo.Fecha(FECHA) as FechaFactura, -- compartir esta fecha en varios puntos de movimientos
		CONVERT(VARCHAR(10), dbo.Fecha(FECHA), 101) as FechaFacturaStr -- compartir esta fecha en varios puntos de movimientos
	-- FROM Score.Factura -- llamar a la tabla remota directamente es ligeramente má eficiente
	FROM serverScore.IT_Rentas_pruebas.dbo.OperFacturas
		join FechaIncluirAPartirDe as F on FECHA >= F.FechaCorte
	WHERE TOTAL <> 0
		AND CANCELADA = 'N'
		AND FOLIO2 = ''
		AND PROCESADA = 'N'
		--  AND ISNULL(T4.FORMADEPAGO,'')<>''
		--  AND (datediff(dd, dbo.Fecha(FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(FECHA), GETDATE()) = 0 AND PROCESADA = 'N')) -- Condicion para que Timbre Facturas al final del dia Sin Checkbox Timbrar
	-- -- En la primer prueba las sig. facturas mostraban descr. null porque no existe el producto en Comercial.
	-- Where IDFACTURA in (466140,466141,460101,451204,449199,445635,424797,428267,428268,428489,428490,402271,404898,409615,412969,414075)
GO

-- dependiente de FacturaPorTimbrar
Create or alter view [Score].[ConFacPorTimbrar]
As
	SELECT con.*
	FROM Score.ConFac as con
		join Score.FacturaPorTimbrar as f on f.IDFACTURA = con.FACTURASNUMERO
GO

-- dependiente de FacturaPorTimbrar
Create or alter view [Score].[ConFacPersPorTimbrar]
As
	SELECT pers.*,
			-- dbo.fn_GetIdConFacOriginalUnico(pers.Id) as IdConFac  puede reemplazarse con 'IdConFacOriginal', que ahora siempre se llena
			IdConFacOriginal as IdConFac
	FROM serverScore.IT_Rentas_pruebas.dbo.OperConFacPers as pers
		join Score.FacturaPorTimbrar as f on f.IDFACTURA = pers.FacturasNumero
GO

if (Object_id('[Score].[KardexAlta]') is null)
	Create synonym [Score].[KardexAlta] for serverScore.IT_Rentas_pruebas.dbo.OperKardexAltas
GO

-- Linea
if (Object_id('[Score].[Linea]') is null)
	Create synonym [Score].[Linea] for serverScore.IT_Rentas_pruebas.dbo.CataLineas

if (Object_id('[Score].[LineaSucursal]') is null)
	Create synonym [Score].[LineaSucursal] for serverScore.IT_Rentas_pruebas.dbo.CataLineasSucursal
GO

-- Linea para importar a Comercial
Create or alter view [Score].[LineaConCodSAT]
As
	SELECT IDLINEA, rtrim(CODSAT) as CODSAT
	FROM Score.Linea
	WHERE CODSAT is not null
GO

-- Modelo
if (Object_id('[Score].[Modelo]') is null)
	Create synonym [Score].[Modelo] for serverScore.IT_Rentas_pruebas.dbo.CataModelos

-- Nota de credito
if (Object_id('[Score].[NotaDeCredito]') is null)
	Create synonym [Score].[NotaDeCredito] for serverScore.IT_Rentas_pruebas.dbo.OperNotasCredito
GO

Create or alter view [Score].[NotaDeCreditoPorTimbrar]
As
	-- Factorizamos las notas de credito a timbrar para compartir entre
	-- documentos y movimientos
	SELECT *,
		dbo.fn_FechaITaETL(FECHA) as FechaStr
		FROM serverScore.IT_Rentas_pruebas.dbo.OperNotasCredito
			join FechaIncluirAPartirDe as F on FECHA >= F.FechaCorte
		WHERE TOTAL <> 0
			AND IDNOTASCREDITO not in (32977)
			AND CERRADO = 'S'
			-- AND 0 = 1 -- Solo pruebas
GO

-- Obra
if (Object_id('[Score].[Obra]') is null)
	Create synonym [Score].[Obra] for serverScore.IT_Rentas_pruebas.dbo.CataObras

-- Orden de trabajo (OT)
if (Object_id('[Score].[OT]') is null)
	Create Synonym [Score].[OT] for serverScore.IT_Rentas_pruebas.dbo.OperOrdenesTrabajo

-- OTRefaccion
if (Object_id('[Score].[OTRefaccion]') is null)
	Create Synonym [Score].[OTRefaccion] for serverScore.IT_Rentas_pruebas.dbo.OperOTRefacciones
GO

-- Orden de trabajo por timbrar (OTPorTimbrar)
Create or alter view [Score].[OTPorTimbrar]
As
	with FechaHoyIT as (
		-- calcular fecha IT hoy uan vez
		select dbo.fn_FechaIT(getdate()) as Hoy
	)
	Select *,
	dbo.fn_FechaITaETL(FECHATERMINADO) AS FechaTerminadoStr
	from Score.OT
		join FechaIncluirAPartirDe as F on FECHATERMINADO >= F.FechaCorte
		join FechaHoyIT as H on FECHATERMINADO <= H.Hoy
	WHERE FACTURASNUMERO = 0
		and (select sum(CANTIDAD - CANTIDADDEVUELTA) from Score.OTRefaccion where ORDENESTRABAJONUMERO = NUMERO) <> 0
		-- and 0 = 1 -- Solo pruebas
GO

-- Pago
if (Object_id('[Score].[Pago]') is null)
	Create Synonym [Score].[Pago] for serverScore.IT_Rentas_pruebas.dbo.OperPagos

-- ParaCentOper
if (Object_id('[Score].[ParaCentOper]') is null)
	Create Synonym [Score].[ParaCentOper] for serverScore.IT_Rentas_pruebas.dbo.ParaCentOper
GO

-- Create or alter view [Score].[ParaCentOper]
-- As
-- 	Select IDCENTROOPERATIVO,
-- 		IDSUCURSAL,
-- 		INICIALES
-- 	from serverScore.IT_Rentas_pruebas.dbo.ParaCentOper
-- GO

-- ParaPreferencias
if (Object_id('[Score].[ParaPreferencias]') is null)
	Create Synonym [Score].[ParaPreferencias] for serverScore.IT_Rentas_pruebas.dbo.ParaPreferencias

-- Create or alter view [Score].[ParaPreferencias]
-- As
-- 	Select IDPREFERENCIAS
-- 	from serverScore.IT_Rentas_pruebas.dbo.ParaPreferencias
-- GO

-- Proveedor
if (Object_id('[Score].[Proveedor]') is null)
	Create Synonym [Score].[Proveedor] for serverScore.IT_Rentas_pruebas.dbo.CataProveedores

-- Refaccion
if (Object_id('[Score].[Refaccion]') is null)
	Create Synonym [Score].[Refaccion] for serverScore.IT_Rentas_pruebas.dbo.CataRefacciones
GO

-- Refacciones aptas para importar
Create or alter view [Score].[RefaccionConCodSAT]
As
	Select IDREFACCION, RTRIM(CODSAT) as CODSAT
	from Score.Refaccion
	where CODSAT is not null
GO

-- Requisición
if (Object_id('[Score].[Requisicion]') is null)
	Create Synonym [Score].[Requisicion] for serverScore.IT_Rentas_pruebas.dbo.OperRequisiciones
GO

Create or alter view [Score].[RequisicionPorTimbrar]
As
	with FechaRec as (
		select IDREQUISICION, FECHARECIBIDA
		from Score.ConReq 
		group by IDREQUISICION, FECHARECIBIDA
	)
	Select T0.*,
		dbo.fn_FechaITaETL(T4.FECHARECIBIDA) AS FechaRecibidaStr
	from Score.Requisicion as T0
		join FechaRec as T4 on T4.IDREQUISICION = T0.IDREQUISICION
		join FechaIncluirAPartirDe as F on T4.FECHARECIBIDA >= F.FechaCorte
	where T0.IDREQUISICION > 8492
		-- and 0 = 1 -- Solo pruebas
GO

-- todo: RequisicionPorTimbrar

-- Recepción de mercancía (RM)
if (Object_id('[Score].[RM]') is null)
	Create Synonym [Score].[RM] for serverScore.IT_Rentas_pruebas.dbo.OperRecepcionMercancia
GO

Create or alter view [Score].[RMPorTimbrar]
As
	Select *,
	dbo.fn_FechaITaETL(FECHADOCUMENTO) as FechaDocumentoStr
	from Score.RM
		join FechaIncluirAPartirDe as F on FECHARECEPCION >= F.FechaCorte
	where Cerrada = 1
		AND Estado = 'Contabilizada'
		and IDRECEPCIONMERCANCIA > 36081
		and IDRECEPCIONMERCANCIA not in (40384, 40639)
		and Tipo NOT IN ('Consignación')
		-- and 0 = 1 -- Solo pruebas
GO

if (Object_id('[Score].[rlnConFac_ConFacPers]') is null)
	Create Synonym [Score].[rlnConFac_ConFacPers] for serverScore.IT_Rentas_pruebas.dbo.rlnOperConFac_OperConFacPers

/* -- Tests
Select top 10 * from Score.Cliente
Select top 10 * from Score.ClienteSucursal
Select top 10 * from Score.ConDev
Select top 10 * from Score.ConFac
Select top 10 * from Score.ConFacPorTimbrar
Select top 10 * from Score.ConFacPersPorTimbrar
Select top 10 * from Score.ConReq
Select top 10 * from Score.ConRM
Select top 10 * from Score.CuentaBanco
Select top 10 * from Score.Deposito
Select top 10 * from Score.DepositoPorTimbrar
Select top 10 * from Score.Devolucion
Select top 10 * from Score.EquipoNuevo
Select top 10 * from Score.EquipoRenta
Select top 10 * from Score.EquipoUsado
Select top 10 * from Score.Factura
Select top 10 * from Score.FacturaPago
Select top 10 * from Score.FacturaPorTimbrar
Select top 10 * from Score.KardexAlta
Select top 10 * from Score.Linea
Select top 10 * from Score.LineaConCodSAT
Select top 10 * from Score.LineaSucursal
Select top 10 * from Score.Modelo
Select top 10 * from Score.NotaDeCredito
Select top 10 * from Score.NotaDeCreditoPorTimbrar
Select top 10 * from Score.Obra
Select top 10 * from Score.OT
Select top 10 * from Score.OTPorTimbrar
Select top 10 * from Score.OTRefaccion
Select top 10 * from Score.Pago
Select top 10 * from Score.ParaCentOper
Select top 10 * from Score.ParaPreferencias
Select top 10 * from Score.Proveedor
Select top 10 * from Score.Refaccion
Select top 10 * from Score.RefaccionConCodSAT
Select top 10 * from Score.Requisicion
Select top 10 * from Score.RM
Select top 10 * from Score.RMPorTimbrar
*/