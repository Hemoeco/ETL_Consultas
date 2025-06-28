/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de concepto desde Comercial
------------------------------------------------------- */

-- use ETL_Prod_Cesar
GO

Create or alter view [Comercial].[Almacen]
As
    SELECT *
    FROM adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admAlmacenes
GO

Create or alter view [Comercial].[Comprobante]
As
    SELECT *
    FROM [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata].dbo.Comprobante
GO

Create or alter view [Comercial].[Concepto]
As
    SELECT *
    FROM adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos
GO

Create or alter view [Comercial].[Documento]
As
    SELECT *
    FROM adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos
GO

Create or alter view [Comercial].[Parametro]
As
    SELECT CIDEMPRESA, CRUTACONTPAQ
    FROM adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admParametros
GO

Create or alter view [Comercial].[Producto]
As
    SELECT *
    FROM adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admProductos
GO

Create or alter view [Comercial].[UnidadMedida]
As
    SELECT *
    FROM adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admUnidadesMedidaPeso
GO

Create or alter view [Comercial].[TipoCambio]
As
    SELECT *
    FROM ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio
GO

Create or alter view [Comercial].[ProductoYUnidad]
As
    SELECT CCODIGOPRODUCTO, 
        CNOMBREPRODUCTO, 
        p.CCLAVESAT as claveProdServSAT, 
        CCLAVEINT as claveUnidadSAT
	FROM adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admProductos AS p
		JOIN adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admUnidadesMedidaPeso AS adu ON adu.CIDUNIDAD = p.CIDUNIDADBASE
GO

/* -- Tests
Select top 10 * from Comercial.Almacen
Select top 10 * from Comercial.Comprobante
Select top 10 * from Comercial.Concepto
Select top 10 * from Comercial.Documento
Select top 10 * from Comercial.Parametro
Select top 10 * from Comercial.Producto
Select top 10 * from Comercial.TipoCambio
Select top 10 * from Comercial.UnidadMedida
*/