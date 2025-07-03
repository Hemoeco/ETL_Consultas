/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de cliente y cliente sucursal
-- desde Score
------------------------------------------------------- */

-- use ETL_Prod_Cesar
GO

-- Cliente y ClienteSucursal
if (Object_id('[Score].[Cliente]') is null)
	Create Synonym [Score].[Cliente] for serverScore.IT_Rentas.dbo.CataClientes

if (Object_id('[Score].[ClienteSucursal]') is null)
	Create Synonym [Score].[ClienteSucursal] for serverScore.IT_Rentas.dbo.CataClientesSucursal

if (Object_id('[Score].[ConDev]') is null)
	Create Synonym [Score].[ConDev] for serverScore.IT_Rentas.dbo.OperConDev

-- Concepto factura
if (Object_id('[Score].[ConFac]') is null)
	Create Synonym [Score].[ConFac] for serverScore.IT_Rentas.dbo.OperConFac

-- Concepto ndc
if (Object_id('[Score].[ConNot]') is null)
	Create Synonym [Score].[ConNot] for serverScore.IT_Rentas.dbo.OperConNot

-- concepto requisicion (ConReq)
if (Object_id('[Score].[ConReq]') is null)
	Create Synonym [Score].[ConReq] for serverScore.IT_Rentas.dbo.OperConReq

if (Object_id('[Score].[ConRM]') is null)
	Create Synonym [Score].[ConRM] for serverScore.IT_Rentas.dbo.OperConRM

-- CuentaBanco
if (Object_id('[Score].[CuentaBanco]') is null)
	Create Synonym [Score].[CuentaBanco] for serverScore.IT_Rentas.dbo.CataCuentasBancos

-- Deposito
if (Object_id('[Score].[Deposito]') is null)
	Create Synonym [Score].[Deposito] for serverScore.IT_Rentas.dbo.OperDepositos

-- Devolucion
if (Object_id('[Score].[Devolucion]') is null)
	Create Synonym [Score].[Devolucion] for serverScore.IT_Rentas.dbo.OperDevoluciones

-- Equipo (Nuevo, Renta y Usado)
if (Object_id('[Score].[EquipoNuevo]') is null)
	Create Synonym [Score].[EquipoNuevo] for serverScore.IT_Rentas.dbo.CataEquiposNuevos

if (Object_id('[Score].[EquipoRenta]') is null)
	Create Synonym [Score].[EquipoRenta] for serverScore.IT_Rentas.dbo.CataEquiposRenta

if (Object_id('[Score].[EquipoUsado]') is null)
	Create Synonym [Score].[EquipoUsado] for serverScore.IT_Rentas.dbo.CataEquiposUsados

-- Factura
if (Object_id('[Score].[Factura]') is null)
	Create synonym [Score].[Factura] for serverScore.IT_Rentas.dbo.OperFacturas

-- FacturaPago
if (Object_id('[Score].[FacturaPago]') is null)
	Create synonym [Score].[FacturaPago] for serverScore.IT_Rentas.dbo.OperFacPag

if (Object_id('[Score].[KardexAlta]') is null)
	Create synonym [Score].[KardexAlta] for serverScore.IT_Rentas.dbo.OperKardexAltas

-- Linea
if (Object_id('[Score].[Linea]') is null)
	Create synonym [Score].[Linea] for serverScore.IT_Rentas.dbo.CataLineas

if (Object_id('[Score].[LineaSucursal]') is null)
	Create synonym [Score].[LineaSucursal] for serverScore.IT_Rentas.dbo.CataLineasSucursal

-- Modelo
if (Object_id('[Score].[Modelo]') is null)
	Create synonym [Score].[Modelo] for serverScore.IT_Rentas.dbo.CataModelos

-- Nota de credito
if (Object_id('[Score].[NotaDeCredito]') is null)
	Create synonym [Score].[NotaDeCredito] for serverScore.IT_Rentas.dbo.OperNotasCredito

-- Obra
if (Object_id('[Score].[Obra]') is null)
	Create synonym [Score].[Obra] for serverScore.IT_Rentas.dbo.CataObras

-- Orden de trabajo (OT)
if (Object_id('[Score].[OT]') is null)
	Create Synonym [Score].[OT] for serverScore.IT_Rentas.dbo.OperOrdenesTrabajo

-- OTRefaccion
if (Object_id('[Score].[OTRefaccion]') is null)
	Create Synonym [Score].[OTRefaccion] for serverScore.IT_Rentas.dbo.OperOTRefacciones

-- Pago
if (Object_id('[Score].[Pago]') is null)
	Create Synonym [Score].[Pago] for serverScore.IT_Rentas.dbo.OperPagos

-- ParaCentOper
if (Object_id('[Score].[ParaCentOper]') is null)
	Create Synonym [Score].[ParaCentOper] for serverScore.IT_Rentas.dbo.ParaCentOper

-- ParaPreferencias
if (Object_id('[Score].[ParaPreferencias]') is null)
	Create Synonym [Score].[ParaPreferencias] for serverScore.IT_Rentas.dbo.ParaPreferencias

-- Proveedor
if (Object_id('[Score].[Proveedor]') is null)
	Create Synonym [Score].[Proveedor] for serverScore.IT_Rentas.dbo.CataProveedores

-- Refaccion
if (Object_id('[Score].[Refaccion]') is null)
	Create Synonym [Score].[Refaccion] for serverScore.IT_Rentas.dbo.CataRefacciones

-- Requisición
if (Object_id('[Score].[Requisicion]') is null)
	Create Synonym [Score].[Requisicion] for serverScore.IT_Rentas.dbo.OperRequisiciones

-- Recepción de mercancía (RM)
if (Object_id('[Score].[RM]') is null)
	Create Synonym [Score].[RM] for serverScore.IT_Rentas.dbo.OperRecepcionMercancia

if (Object_id('[Score].[rlnConFac_ConFacPers]') is null)
	Create Synonym [Score].[rlnConFac_ConFacPers] for serverScore.IT_Rentas.dbo.rlnOperConFac_OperConFacPers

/* -- Tests
Select top 10 * from Score.Cliente
Select top 10 * from Score.ClienteSucursal
Select top 10 * from Score.ConDev
Select top 10 * from Score.ConFac
Select top 10 * from Score.ConReq
Select top 10 * from Score.ConRM
Select top 10 * from Score.CuentaBanco
Select top 10 * from Score.Deposito
Select top 10 * from Score.Devolucion
Select top 10 * from Score.EquipoNuevo
Select top 10 * from Score.EquipoRenta
Select top 10 * from Score.EquipoUsado
Select top 10 * from Score.Factura
Select top 10 * from Score.FacturaPago
Select top 10 * from Score.KardexAlta
Select top 10 * from Score.Linea
Select top 10 * from Score.LineaConCodSAT
Select top 10 * from Score.LineaSucursal
Select top 10 * from Score.Modelo
Select top 10 * from Score.NotaDeCredito
Select top 10 * from Score.Obra
Select top 10 * from Score.OT
Select top 10 * from Score.OTRefaccion
Select top 10 * from Score.Pago
Select top 10 * from Score.ParaCentOper
Select top 10 * from Score.ParaPreferencias
Select top 10 * from Score.Proveedor
Select top 10 * from Score.Refaccion
Select top 10 * from Score.RefaccionConCodSAT
Select top 10 * from Score.Requisicion
Select top 10 * from Score.RM

Select count(1) as Depositos from Score.DepositoPorTimbrar
Select count(1) as Facturas from Score.FacturaPorTimbrar
Select count(1) as NotasDeCredito from Score.NotaDeCreditoPorTimbrar
Select count(1) as OTs from Score.OTPorTimbrar
Select count(1) as Requisiciones from Score.RequisicionPorImportar
Select count(1) as RMs from Score.RMPorTimbrar
*/
