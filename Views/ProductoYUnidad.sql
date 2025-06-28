/* ----------------------------------------------------
-- Hemoeco Renta (2025)
-- Script: ProductoYUnidad.sql
-- Vista para la consulta de productos con nombre de 
-- unidad en Comercial
------------------------------------------------------- */

Create or alter view [Comercial].[ProductoYUnidad]
As
    SELECT CCODIGOPRODUCTO, 
        CNOMBREPRODUCTO, 
        p.CCLAVESAT as claveProdServSAT, 
        CCLAVEINT as claveUnidadSAT
	FROM Comercial.Producto AS p
		JOIN Comercial.UnidadMedida AS adu ON adu.CIDUNIDAD = p.CIDUNIDADBASE
GO