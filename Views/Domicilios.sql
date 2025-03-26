SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Domicilios] AS
select 1 as cTipoCatalogo,
	convert(varchar,T0.IDCLIENTE) as cCodigoCatalogo,
    T2.cTipoDireccion as cTipoDireccion,
	RTRIM(T0.CALLE) AS cNombreCalle,
	ISNULL(RTRIM(T0.NUMEXT), 'S/N') AS cNumeroExterior,
	ISNULL(RTRIM(T0.NUMINT), 'S/N') AS cNumeroInterior,
	RTRIM(T0.COLONIA) AS cColonia,
	rtrim(T0.CP) AS cCodigoPostal,
	RTRIM(T0.MUNICIPIODELEGACION) AS cMunicipio,
	case RTRIM(T0.ESTADO) when 'DF' then 'Ciudad de Mexico' else RTRIM(T0.ESTADO) end AS cEstado,
	case when rtrim(T0.PAIS)='MX' then 'México' else rtrim(T0.PAIS) end AS cPais
FROM [192.168.111.14].IT_Rentas.dbo.CataClientes T0,
	(select 0 as cTipoDireccion union select 1) as T2
UNION ALL select 3 as cTipoCatalogo,
	'FAC' + CONVERT(varchar, T0.IDFACTURA) as cCodigoCatalogo,
    0 as cTipoDireccion,
	RTRIM(T1.CALLE) AS cNombreCalle,
	ISNULL(T1.NUMEXT, 'S/N') AS cNumeroExterior,
	ISNULL(T1.NUMINT, 'S/N') AS cNumeroInterior,
	RTRIM(T1.COLONIA) AS cColonia,
	rtrim(T1.CP) AS cCodigoPostal,
	RTRIM(T1.MUNICIPIODELEGACION) AS cMunicipio,
	case RTRIM(T1.ESTADO) when 'DF' then 'Ciudad de Mexico' else RTRIM(T1.ESTADO) end AS cEstado,
	case when rtrim(T1.PAIS)='MX' then 'México' else rtrim(T1.PAIS) end AS cPais
FROM [192.168.111.14].IT_Rentas.dbo.OperFacturas T0
	inner join [192.168.111.14].IT_Rentas.dbo.CataClientes T1 on T0.CLIENTESNUMERO = T1.IDCLIENTE-- and T0.IDSUCURSAL=T1.IDSUCURSAL
GO
