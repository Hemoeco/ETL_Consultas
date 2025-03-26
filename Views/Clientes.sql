SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Clientes] AS
SELECT convert(varchar,T0.IDCLIENTE) AS cCodigoCliente,
	RTRIM(T0.RAZONSOCIAL) AS cRazonSocial,
	case when RTRIM(T0.RFC)='XAXX010101000' then 'PUBLICO EN GENERAL.' else RTRIM(isnull(T0.NOMBREFISCAL,'')) end AS cNombreLargo,
	RTRIM(T0.RFC) AS cRFC,
	1 AS cTipoCliente,
	2 AS cIdMoneda,
	1 AS cIdMoneda2,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCFDI, ';') where column_id=1) as cEmail1,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCFDI, ';') where column_id=2) as cEmail2,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCFDI, ';') where column_id=3) as cEmail3,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCFDI, ';') where column_id=4) as cTextoExtra1,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCFDI, ';') where column_id=5) as cTextoExtra2,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCFDI, ';') where column_id=6) as cTextoExtra3,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCOMP, ';') where column_id=1) as cTextoExtra4,
	(SELECT value FROM fn_split_string_to_column(T1.EMAILCOMP, ';') where column_id=2) as cTextoExtra5,
	max(T1.limitecredito) as cLimiteCreditoCliente,
	max(T1.diascredito) as cDiasCreditoCliente,
	1 as cEstatus,
	isnull(T1.USOCFDI,'P01') as cUsoCFDI,
	isnull(T0.REGIMENFISCAL,'') as cRegimFisc
FROM [192.168.111.14].IT_Rentas.dbo.CataClientes T0
	inner join [192.168.111.14].IT_Rentas.dbo.CataClientesSucursal T1 on T0.IDCLIENTE = T1.IDNUMERO
	inner join Documentos D on cCodigoCteProv = convert(varchar,T0.IDCLIENTE) and D.cImporteExtra1 = T1.idsucursal
--where convert(varchar,T0.IDCLIENTE) = (select distinct cCodigoCteProv from Documentos)
group by T0.IDCLIENTE, T0.IDCLIENTE, T0.RAZONSOCIAL, T0.NOMBREFISCAL, T0.RFC, T0.CALLENUMERO, T0.COLONIA, T0.CP, T0.MUNICIPIODELEGACION,
	T0.ESTADO, T0.PAIS, T1.EMAILCFDI, T1.USOCFDI, T0.REGIMENFISCAL, T1.EMAILCOMP
union
SELECT 'P' + REPLICATE('0', 5 - LEN(T0.IDPROVEEDOR)) + CONVERT(varchar, T0.IDPROVEEDOR) AS cCodigoCliente,
	RTRIM(T0.RAZONSOCIAL) AS cRazonSocial,
	'' AS cNombreLargo,
	RTRIM(T0.RFC) AS cRFC,
	3 AS cTipoCliente,
	2 AS cIdMoneda,
	1 AS cIdMoneda2,
	'' AS cEmail1,
	'' AS cEmail2,
	'' AS cEmail3,
	'' AS cTextoExtra1,
	'' AS cTextoExtra2,
	'' AS cTextoExtra3,
	'' AS cTextoExtra4,
	'' AS cTextoExtra5,
	0 as cLimiteCreditoCliente,
	0 as cDiasCreditoCliente,
	1 as cEstatus,
	'' as cUsoCFDI,
	'' as cRegimFisc
FROM [192.168.111.14].IT_Rentas.dbo.CataProveedores T0
where 'P' + REPLICATE('0', 5 - LEN(T0.IDPROVEEDOR)) + CONVERT(varchar, T0.IDPROVEEDOR) in (select cCodigoCteProv from Documentos)
GO
