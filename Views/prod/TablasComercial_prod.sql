/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de concepto desde Comercial
------------------------------------------------------- */

-- use ETL_Prod_Cesar
GO

if (Object_id('[Comercial].[Almacen]') is null)
    Create Synonym [Comercial].[Almacen] for adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admAlmacenes
GO

if (Object_id('[Comercial].[Comprobante]') is null)
    Create Synonym [Comercial].[Comprobante] for [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata].dbo.Comprobante
GO

if (Object_id('[Comercial].[Concepto]') is null)
    Create Synonym [Comercial].[Concepto] for adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admConceptos
GO

if (Object_id('[Comercial].[Documento]') is null)
    Create Synonym [Comercial].[Documento] for adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admDocumentos
GO

if (Object_id('[Comercial].[Parametro]') is null)
    Create Synonym [Comercial].[Parametro] for adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admParametros
GO

if (Object_id('[Comercial].[Producto]') is null)
    Create Synonym [Comercial].[Producto] for adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admProductos
GO

if (Object_id('[Comercial].[UnidadMedida]') is null)
    Create Synonym [Comercial].[UnidadMedida] for adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admUnidadesMedidaPeso
GO

if (Object_id('[Comercial].[TipoCambio]') is null)
    Create Synonym [Comercial].[TipoCambio] for ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio
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