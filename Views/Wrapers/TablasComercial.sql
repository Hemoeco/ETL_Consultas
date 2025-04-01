/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de concepto desde Comercial
------------------------------------------------------- */

Create or alter view [Comercial].[Almacen]
As
    SELECT *
    FROM serverContabilidad.adhemoeco_prueba.dbo.admAlmacenes
GO

Create or alter view [Comercial].[Comprobante]
As
    SELECT *
    FROM serverContabilidad.[document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata].dbo.Comprobante
GO

Create or alter view [Comercial].[Concepto]
As
    SELECT *
    FROM serverContabilidad.adhemoeco_prueba.dbo.admConceptos
GO

Create or alter view [Comercial].[Documento]
As
    SELECT *
    FROM serverContabilidad.adhemoeco_prueba.dbo.admDocumentos
GO

Create or alter view [Comercial].[Parametro]
As
    SELECT CIDEMPRESA, CRUTACONTPAQ
    FROM serverContabilidad.adhemoeco_prueba.dbo.admParametros
GO

Create or alter view [Comercial].[Producto]
As
    SELECT *
    FROM serverContabilidad.adhemoeco_prueba.dbo.admProductos
GO

Create or alter view [Comercial].[TipoCambio]
As
    SELECT *
    FROM serverContabilidad.ctHemoeco_Renta_SA_de_CV_2016.dbo.TiposCambio
GO

/* -- Tests
Select top 10 * from Comercial.Almacen
Select top 10 * from Comercial.Comprobante
Select top 10 * from Comercial.Concepto
Select top 10 * from Comercial.Documento
Select top 10 * from Comercial.Parametro
Select top 10 * from Comercial.Producto
Select top 10 * from Comercial.TipoCambio
*/