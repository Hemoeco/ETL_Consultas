/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para la consulta de importación de producto
-- lee los documentos de Score para importarlos a Comercial
------------------------------------------------------- */

ALTER VIEW [dbo].[Productos] AS
select T0.*
from (SELECT 'REF' + convert(varchar,IDREFACCION) AS cCodigoProducto,
	'VENTA REFACCION' AS cNombreProducto,
	1 AS cTipoProducto,
	1 AS cMetodoCosteo,
	1 AS cControlExistencia, 
    'PIEZA' AS cNombreUnidadBase,
    0 AS cImpuesto1,
    CODSAT as cClaveSAT
FROM Score.Refaccion
where CODSAT is not null
UNION SELECT 'MOD' + convert(varchar,IDLINEA) AS cCodigoProducto,
	'VENTA EQUIPO' AS cNombreProducto,
	1 AS cTipoProducto,
	1 AS cMetodoCosteo,
	1 AS cControlExistencia, 
	'PIEZA' AS cNombreUnidadBase,
	0 AS cImpuesto1,
    rtrim(CODSAT) as cClaveSAT
FROM Score.Linea
WHERE CODSAT is not null
UNION SELECT 'SRV' AS cCodigoProducto,
	'SERVICIO' AS cNombreProducto,
	3 AS cTipoProducto,
	7 AS cMetodoCosteo,
	1 AS cControlExistencia, 
	'SERVICIO' AS cNombreUnidadBase,
	0 AS cImpuesto1,
    '72101500' as cClaveSAT
UNION SELECT 'REN' AS cCodigoProducto,
	'RENTA' AS cNombreProducto,
	3 AS cTipoProducto,
	7 AS cMetodoCosteo,
	1 AS cControlExistencia,
	'DIA(S)' AS cNombreUnidadBase,
	0 AS cImpuesto1,
    '72141700' as cClaveSAT) as T0
left join Comercial.Producto T5 on T0.cCodigoProducto = T5.cCodigoProducto and T0.cTipoProducto = T5.cTipoProducto and T0.cNombreProducto = T5.cNombreProducto and T0.cClaveSAT = T5.cClaveSAT
where T5.cidproducto is null
GO

-- Test
Select top 10 * from Productos