/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener las facturas desde Score
------------------------------------------------------- */

-- Drop View If Exists [Score].[Factura]
-- GO

Create or alter view [Score].[Factura]
As
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
        PORCENTAJEIVA
    FROM [192.168.111.14].IT_Rentas_pruebas.dbo.OperFacturas
GO

-- Tests
-- Select top 10 * from Score.Factura