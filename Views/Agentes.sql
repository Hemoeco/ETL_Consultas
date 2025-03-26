SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Agentes] as
select IDEMPLEADO as cCodigoAgente, upper(rtrim(NOMBRECOMPLETO)) as cNombreAgente, 2 as cTipoAgente,
	lower(rtrim(T0.correoelectronico)) + '@hemoeco.com' as cTextoExtra1
from [192.168.111.14].IT_Rentas.dbo.CataEmpleados T0
--	left join adHEMOECO_RENTA_SA_DE_CV_2018.dbo.admAgentes T1 on convert(varchar,T0.IDEMPLEADO) = T1.cCodigoAgente and T0.NOMBRECOMPLETO = T1.cNombreAgente
where IDEMPLEADO in (select distinct IDEMPLEADO
					  from [192.168.111.14].IT_Rentas.dbo.OperFacturas
					  where TOTAL <> 0
						AND CANCELADA = 'N'
					    AND FOLIO2 = ''
					    AND YEAR(dbo.fecha(FECHA)) >= 2018
					    AND (datediff(dd, dbo.Fecha(FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(FECHA), GETDATE()) = 0 AND PROCESADA = 'N')))
--  and T1.cidagente is null
GO
