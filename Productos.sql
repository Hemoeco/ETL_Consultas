SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
FROM [192.168.111.14].IT_Rentas_Pruebas.dbo.CataRefacciones
where CODSAT is not null
UNION SELECT 'MOD' + convert(varchar,IDLINEA) AS cCodigoProducto,
	'VENTA EQUIPO' AS cNombreProducto,
	1 AS cTipoProducto,
	1 AS cMetodoCosteo,
	1 AS cControlExistencia, 
	'PIEZA' AS cNombreUnidadBase,
	0 AS cImpuesto1,
    rtrim(CODSAT) as cClaveSAT
FROM [192.168.111.14].IT_Rentas_Pruebas.dbo.CataLineas
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
    '72141700' as cClaveSAT
UNION SELECT 'MREN' AS cCodigoProducto, -- usado en XML_ETIQUETA3 para utilizar código mes
            'RENTA' AS cNombreProducto,
            3 AS cTipoProducto,
            7 AS cMetodoCosteo,
            1 AS cControlExistencia,
            'MES(ES)' AS cNombreUnidadBase, -- todo: validar este campo
            --N'MON - Mes' as ClaveUnidadSAT,
            0 AS cImpuesto1,
            '72141700' as cClaveSAT) as T0
left join adhemoeco_prueba.dbo.admProductos T5 on T0.cCodigoProducto = T5.cCodigoProducto and T0.cTipoProducto = T5.cTipoProducto and T0.cNombreProducto = T5.cNombreProducto and T0.cClaveSAT = T5.cClaveSAT
where T5.cidproducto is null
GO
