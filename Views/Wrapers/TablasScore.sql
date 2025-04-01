/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de cliente y cliente sucursal
-- desde Score
------------------------------------------------------- */

use ETL_Pruebas

-- Drop View If Exists [Score].[Cliente]
-- GO

-- Cliente y ClienteSucursal
Create or alter view [Score].[Cliente]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataClientes
GO

Create or alter view [Score].[ClienteSucursal]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataClientesSucursal
GO

Create or alter view [Score].[ConDev]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperConDev
GO

-- Concepto factura
Create or alter view [Score].[ConFac]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.OperConFac
GO

-- Concepto ndc
Create or alter view [Score].[ConNot]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.OperConNot
GO

-- concepto requisicion (ConReq)
Create or alter view [Score].[ConReq]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperConReq
GO

Create or alter view [Score].[ConRM]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperConRM
GO

-- CuentaBanco
Create or alter view [Score].[CuentaBanco]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.CataCuentasBancos
GO

-- Deposito
Create or alter view [Score].[Deposito]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperDepositos
GO

-- todo: DepositoPorTimbrar

-- Devolucion
Create or alter view [Score].[Devolucion]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperDevoluciones
GO

-- Equipo (Nuevo, Renta y Usado)
Create or alter view [Score].[EquipoNuevo]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataEquiposNuevos
GO

Create or alter view [Score].[EquipoRenta]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataEquiposRenta
GO

Create or alter view [Score].[EquipoUsado]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataEquiposUsados
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
        CONVERT(VARCHAR(10), dbo.Fecha(FECHA), 101) as FechaFacturaStr -- compartir esta fecha en varios puntos de movimientos,
    FROM serverScore.IT_Rentas_pruebas.dbo.OperFacturas
GO

-- FacturaPago
Create or alter view [Score].[FacturaPago]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperFacPag
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
    WHERE TOTAL <> 0
        AND CANCELADA = 'N'
        AND FOLIO2 = ''
        AND PROCESADA = 'N'
        --  AND ISNULL(T4.FORMADEPAGO,'')<>''
        AND FECHA >= 80723 -- 2022-01-01 00:00:00.000
        --  AND (datediff(dd, dbo.Fecha(FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(FECHA), GETDATE()) = 0 AND PROCESADA = 'N')) -- Condicion para que Timbre Facturas al final del dia Sin Checkbox Timbrar
GO

Create or alter view [Score].[KardexAlta]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.OperKardexAltas
GO

-- Linea
Create or alter view [Score].[Linea]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataLineas
GO

Create or alter view [Score].[LineaSucursal]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataLineasSucursal
GO

-- Modelo
Create or alter view [Score].[Modelo]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.CataModelos
GO

-- Nota de credito
Create or alter view [Score].[NotaDeCredito]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.OperNotasCredito
GO

Create or alter view [Score].[NotaDeCreditoPorTimbrar]
As
    -- Factorizamos las notas de credito a timbrar para compartir entre
    -- documentos y movimientos
    SELECT *
        FROM serverScore.IT_Rentas_pruebas.dbo.OperNotasCredito
        WHERE TOTAL <> 0
            -- AND YEAR(dbo.fecha(T0.FECHA)) >= 2024 -- esta condicion se incluye abajo
            -- and dbo.fecha(T0.FECHA) >= '20240131'
            AND FECHA >= 81483 -- 31/01/2024
            --  AND datediff(dd, dbo.Fecha(T0.FECHA), GETDATE()) <= 3
            AND IDNOTASCREDITO not in (32977)
            AND CERRADO = 'S'
            --  and dbo.fecha(T0.FECHA) >='20220901'
GO

-- Obra
Create or alter view [Score].[Obra]
As
    SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.CataObras
GO

-- Orden de trabajo (OT)
Create or alter view [Score].[OT]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperOrdenesTrabajo
GO

-- OTRefaccion
Create or alter view [Score].[OTRefaccion]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperOTRefacciones
GO

-- Orden de trabajo por timbrar (OTPorTimbrar)
Create or alter view [Score].[OTPorTimbrar]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperOrdenesTrabajo
    WHERE FECHATERMINADO >= 80723 -- '20220101'. test: print dbo.Fecha(80723)
        AND FECHATERMINADO <= dbo.fn_FechaIT(getdate()) -- Hoy. Test: print dbo.fn_FechaIT(getdate())
        AND FACTURASNUMERO = 0
        and (select sum(CANTIDAD - CANTIDADDEVUELTA) from serverScore.IT_Rentas_pruebas.dbo.OperOTRefacciones where ORDENESTRABAJONUMERO = NUMERO) <> 0
GO

-- Pago
Create or alter view [Score].[Pago]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperPagos
GO

-- ParaCentOper
Create or alter view [Score].[ParaCentOper]
As
    Select IDCENTROOPERATIVO,
        IDSUCURSAL,
        INICIALES
    from serverScore.IT_Rentas_pruebas.dbo.ParaCentOper
GO

-- ParaPreferencias
Create or alter view [Score].[ParaPreferencias]
As
    Select IDPREFERENCIAS
    from serverScore.IT_Rentas_pruebas.dbo.ParaPreferencias
GO

-- Proveedor
Create or alter view [Score].[Proveedor]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.CataProveedores
GO

-- Refaccion
Create or alter view [Score].[Refaccion]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.CataRefacciones
GO

-- Requisición
Create or alter view [Score].[Requisicion]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperRequisiciones
GO

-- todo: RequisicionPorTimbrar

-- Recepción de mercancía (RM)
Create or alter view [Score].[RM]
As
    Select *
    from serverScore.IT_Rentas_pruebas.dbo.OperRecepcionMercancia
GO

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
Select top 10 * from Score.FacturaPorTimbrar
Select top 10 * from Score.KardexAlta
Select top 10 * from Score.Linea
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
Select top 10 * from Score.Requisicion
Select top 10 * from Score.RM
-- todo: DepositoPorTimbrar
*/