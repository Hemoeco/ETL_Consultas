/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de cliente y cliente sucursal
-- desde Score
------------------------------------------------------- */

-- use ETL_Prod_Cesar
GO

-- Drop View If Exists [Score].[Cliente]
-- GO

-- Cliente y ClienteSucursal
Create or alter view [Score].[Cliente]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataClientes
GO

Create or alter view [Score].[ClienteSucursal]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataClientesSucursal
GO

Create or alter view [Score].[ConDev]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperConDev
GO

-- Concepto factura
Create or alter view [Score].[ConFac]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.OperConFac
GO

-- Concepto personalizado factura
-- Create or alter view [Score].[ConFacPers]
-- As
-- 	SELECT *
-- 	FROM serverScore.IT_Rentas.dbo.OperConFacPers
-- GO

-- Concepto ndc
Create or alter view [Score].[ConNot]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.OperConNot
GO

-- concepto requisicion (ConReq)
Create or alter view [Score].[ConReq]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperConReq
GO

Create or alter view [Score].[ConRM]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperConRM
GO

-- CuentaBanco
Create or alter view [Score].[CuentaBanco]
As
	Select *
	from serverScore.IT_Rentas.dbo.CataCuentasBancos
GO

-- Deposito
Create or alter view [Score].[Deposito]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperDepositos
GO

Create or alter view [Score].[DepositoPorTimbrar]
As
	Select OD.*,
		dbo.fn_FechaITaETL(OD.FECHA) AS FechaStr
	from serverScore.IT_Rentas.dbo.OperDepositos as OD
		cross join FechaIIncluirAPartirDe as F
	where OD.FECHA >= F.FechaCorte
		and OD.TIMBRAR='S'
		-- and OD.IDDEPOSITO > 405000 -- Solo pruebas
GO

-- Devolucion
Create or alter view [Score].[Devolucion]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperDevoluciones
GO

-- Equipo (Nuevo, Renta y Usado)
Create or alter view [Score].[EquipoNuevo]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataEquiposNuevos
GO

Create or alter view [Score].[EquipoRenta]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataEquiposRenta
GO

Create or alter view [Score].[EquipoRentaDadoDeAlta]
As
	SELECT T0.*,
		CONVERT(VARCHAR(10), dbo.fecha(T0.FECHAALTASUCURSAL), 101) AS FechaAltaSucursalStr
	FROM serverScore.IT_Rentas.dbo.CataEquiposRenta as T0
		cross join FechaIIncluirAPartirDe as F
	WHERE T0.PROPIETARIO = 'Hemoeco' 
		AND T0.FECHAALTAHEMOECO >= F.FechaCorte
GO

Create or alter view [Score].[EquipoUsado]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataEquiposUsados
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
	FROM serverScore.IT_Rentas.dbo.OperFacturas
GO

-- FacturaPago
Create or alter view [Score].[FacturaPago]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperFacPag
GO

Create or alter view [Score].[FacturaPorTimbrar]
As
	-- Factorizamos las notas de credito a timbrar para compartir entre
	-- documentos y movimientos
	SELECT *,
		dbo.Fecha(FECHA) as FechaFactura, -- compartir esta fecha en varios puntos de movimientos
		CONVERT(VARCHAR(10), dbo.Fecha(FECHA), 101) as FechaFacturaStr -- compartir esta fecha en varios puntos de movimientos
	-- FROM Score.Factura -- llamar a la tabla remota directamente es ligeramente má eficiente
	FROM serverScore.IT_Rentas.dbo.OperFacturas
		cross join FechaIIncluirAPartirDe as F
	WHERE TOTAL <> 0
		AND CANCELADA = 'N'
		AND FOLIO2 = ''
		AND PROCESADA = 'N'
		--  AND ISNULL(T4.FORMADEPAGO,'')<>''
		AND FECHA >= F.FechaCorte
		--  AND (datediff(dd, dbo.Fecha(FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(FECHA), GETDATE()) = 0 AND PROCESADA = 'N')) -- Condicion para que Timbre Facturas al final del dia Sin Checkbox Timbrar
	-- -- En la primer prueba las sig. facturas mostraban descr. null porque no existe el producto en Comercial.
	-- Where IDFACTURA in (466140,466141,460101,451204,449199,445635,424797,428267,428268,428489,428490,402271,404898,409615,412969,414075)
GO

-- dependiente de FacturaPorTimbrar
Create or alter view [Score].[ConFacPorTimbrar]
As
	SELECT con.*
	FROM serverScore.IT_Rentas.dbo.OperConFac as con
		join Score.FacturaPorTimbrar as f on f.IDFACTURA = con.FACTURASNUMERO
GO

-- dependiente de FacturaPorTimbrar
Create or alter view [Score].[ConFacPersPorTimbrar]
As
	SELECT pers.*,
			-- dbo.fn_GetIdConFacOriginalUnico(pers.Id) as IdConFac  puede reemplazarse con 'IdConFacOriginal', que ahora siempre se llena
			IdConFacOriginal as IdConFac
	FROM serverScore.IT_Rentas.dbo.OperConFacPers as pers
		join Score.FacturaPorTimbrar as f on f.IDFACTURA = pers.FacturasNumero
GO

Create or alter view [Score].[KardexAlta]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.OperKardexAltas
GO

-- Linea
Create or alter view [Score].[Linea]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataLineas
GO

Create or alter view [Score].[LineaSucursal]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataLineasSucursal
GO

-- Linea para importar a Comercial
Create or alter view [Score].[LineaConCodSAT]
As
	SELECT IDLINEA, rtrim(CODSAT) as CODSAT
	FROM serverScore.IT_Rentas.dbo.CataLineas
	WHERE CODSAT is not null
GO

-- Modelo
Create or alter view [Score].[Modelo]
As
	Select *
	from serverScore.IT_Rentas.dbo.CataModelos
GO

-- Nota de credito
Create or alter view [Score].[NotaDeCredito]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.OperNotasCredito
GO

Create or alter view [Score].[NotaDeCreditoPorTimbrar]
As
	-- Factorizamos las notas de credito a timbrar para compartir entre
	-- documentos y movimientos
	SELECT *,
		dbo.fn_FechaITaETL(FECHA) as FechaStr
		FROM serverScore.IT_Rentas.dbo.OperNotasCredito
			cross join FechaIIncluirAPartirDe as F
		WHERE TOTAL <> 0
			AND FECHA >= F.FechaCorte
			AND IDNOTASCREDITO not in (32977)
			AND CERRADO = 'S'
GO

-- Obra
Create or alter view [Score].[Obra]
As
	SELECT *
	FROM serverScore.IT_Rentas.dbo.CataObras
GO

-- Orden de trabajo (OT)
Create or alter view [Score].[OT]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperOrdenesTrabajo
GO

-- OTRefaccion
Create or alter view [Score].[OTRefaccion]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperOTRefacciones
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
	from serverScore.IT_Rentas.dbo.OperOrdenesTrabajo
		cross join FechaIIncluirAPartirDe as F
		cross join FechaHoyIT as H
	WHERE FECHATERMINADO BETWEEN F.FechaCorte and H.Hoy
		AND FACTURASNUMERO = 0
		and (select sum(CANTIDAD - CANTIDADDEVUELTA) from serverScore.IT_Rentas.dbo.OperOTRefacciones where ORDENESTRABAJONUMERO = NUMERO) <> 0
GO

-- Pago
Create or alter view [Score].[Pago]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperPagos
GO

-- ParaCentOper
Create or alter view [Score].[ParaCentOper]
As
	Select IDCENTROOPERATIVO,
		IDSUCURSAL,
		INICIALES
	from serverScore.IT_Rentas.dbo.ParaCentOper
GO

-- ParaPreferencias
Create or alter view [Score].[ParaPreferencias]
As
	Select IDPREFERENCIAS
	from serverScore.IT_Rentas.dbo.ParaPreferencias
GO

-- Proveedor
Create or alter view [Score].[Proveedor]
As
	Select *
	from serverScore.IT_Rentas.dbo.CataProveedores
GO

-- Refaccion
Create or alter view [Score].[Refaccion]
As
	Select *
	from serverScore.IT_Rentas.dbo.CataRefacciones
GO

-- Refacciones aptas para importar
Create or alter view [Score].[RefaccionConCodSAT]
As
	Select IDREFACCION, RTRIM(CODSAT) as CODSAT
	from serverScore.IT_Rentas.dbo.CataRefacciones
	where CODSAT is not null
GO

-- Requisición
Create or alter view [Score].[Requisicion]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperRequisiciones
GO

Create or alter view [Score].[RequisicionPorTimbrar]
As
	Select T0.*,
		CONVERT(VARCHAR(10), dbo.fecha(T4.FECHARECIBIDA), 101) AS FechaRecibidaStr
	from serverScore.IT_Rentas.dbo.OperRequisiciones as T0
		cross join FechaIIncluirAPartirDe as F
		inner join (select IDREQUISICION, FECHARECIBIDA from serverScore.IT_Rentas.dbo.OperConReq group by IDREQUISICION, FECHARECIBIDA) T4 on T0.IDREQUISICION = T4.IDREQUISICION
	where T0.IDREQUISICION > 8492
		and T4.FECHARECIBIDA >= F.FechaCorte
GO

-- todo: RequisicionPorTimbrar

-- Recepción de mercancía (RM)
Create or alter view [Score].[RM]
As
	Select *
	from serverScore.IT_Rentas.dbo.OperRecepcionMercancia
GO

Create or alter view [Score].[RMPorTimbrar]
As
	Select *,
	dbo.fn_FechaITaETL(FECHADOCUMENTO) as FechaDocumentoStr
	from serverScore.IT_Rentas.dbo.OperRecepcionMercancia
		cross join FechaIIncluirAPartirDe as F
	where FECHARECEPCION >= F.FechaCorte
		AND Cerrada = 1
		AND Estado = 'Contabilizada'
		and IDRECEPCIONMERCANCIA > 36081
		and IDRECEPCIONMERCANCIA not in (40384, 40639)
		and Tipo NOT IN ('Consignación')
GO


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