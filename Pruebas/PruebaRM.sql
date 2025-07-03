-- Medidas principales
Select * from Documentos  -- ETL_Pruebas_Cesar: 9 seg, 4,420 reg; etlPRUEBA: 11 seg, 4,420 reg
Select * from Documentos order by cIdDocumento

Select * from Movimientos  -- ETL_Prod_Cesar: 4 seg, 10 reg; etlHemoeco: 24 seg,  15,929 reg
Select * from Movimientos order by cIdDocumento, cCodigoProducto



-- Pruebas para medir la eficiencia entre view and function.
Create or alter view FechaIncluirAPartirDe
as 
    Select dbo.fn_FechaIT(getdate()) - 360 as FechaCorte

go

Create or alter function [dbo].[fn_FechaIncluirAPartirDe] ()
returns int
AS
Begin
    -- Fecha de corte para la consulta de documentos
    -- considerar los movimientos a partir de los últimos 90 días
    RETURN dbo.fn_FechaIT(getdate()) - 190;
End

GO

Select *
from OperRecepcionMercancia
    cross join FechaIncluirAPartirDe as F
where FECHARECEPCION >= F.FechaCorte
    AND Cerrada = 1
    AND Estado = 'Contabilizada'
    and IDRECEPCIONMERCANCIA > 36081
    and IDRECEPCIONMERCANCIA not in (40384, 40639)
    and Tipo NOT IN ('Consignación')

Select *
from OperRecepcionMercancia
where FECHARECEPCION >= dbo.fn_FechaIncluirAPartirDe()
    AND Cerrada = 1
    AND Estado = 'Contabilizada'
    and IDRECEPCIONMERCANCIA > 36081
    and IDRECEPCIONMERCANCIA not in (40384, 40639)
    and Tipo NOT IN ('Consignación')


-- para comparar
Select * from etlPrueba.dbo.Documentos order by cIdDocumento
Select * from Documentos order by cIdDocumento

Select count(*) from etlPrueba.dbo.Documentos
Select count(*) from Documentos

Select * from [Score].[OTPorTimbrar]
Select * from Documentos where cIdDocumento like 'ODT%'

Select * from etlPrueba.dbo.Documentos where cIdDocumento like 'REC%'
Select * from Documentos where cIdDocumento like 'REC%'

Select * from etlPrueba.dbo.Movimientos
Select * from Movimientos

-- El mismo resultado en ambas consultas indica resultado correcto
Select count(1) from Documentos where cIdDocumento like 'REC%'
Select count(1) from Score.RMPorTimbrar

-- 
USE ETLprueba
GO
Select * from Documentos  -- ETL_Pruebas_Cesar: 9 seg, 4,420 reg; etlPRUEBA: 11 seg, 4,420 reg
Select * from Documentos order by cIdDocumento
Select count(*) from Documentos
Select count(*) from Movimientos

Select count(1) from Documentos where cIdDocumento like 'REC%'
Select count(1) from Score.RMPorTimbrar
Select * from Score.RMPorTimbrar

Select count(1) from Documentos where cIdDocumento like 'ODT%'
Select count(1) from Score.OTPorTimbrar
Select * from Score.OTPorTimbrar

Select dbo.Fecha(etlPrueba.dbo.fn_FechaIncluirAPartirDe())

-- Equipo renta dado de alta
Select * from Documentos where cIdDocumento like 'TR%'
-- drop view Score.EquipoRentaDadoDeAlta

-- nota de credito
Select * from Score.NotaDeCreditoPorTimbrar order by IDNOTASCREDITO

-- Conceptos de factura
Select * from Score.ConFacPorTimbrar

	SELECT con.*
	FROM Score.ConFac as con
		join Score.FacturaPorTimbrar as f on f.IDFACTURA = con.FACTURASNUMERO

	SELECT con.*
	FROM Score.FacturaPorTimbrar as f
		join Score.ConFac as con on con.FACTURASNUMERO =  f.IDFACTURA


-- Conceptos de recepción de mercancía

SELECT 'REC' + rtrim(T1.IDRECEPCIONMERCANCIA) AS cIdDocumento,
	case when T0.IDREFACCION + T0.IDMODELO = 0 then '6111100002' else case when T0.IDREFACCION <> 0 then '11602' else '11601' end + dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + '001' end AS cCodigoProducto, 
	T0.CANTIDADRECIBIDA AS cUnidades,
	T0.PRECIOUNITARIO AS cPrecio,
	--T0.CANTIDADRECIBIDA * T0.PRECIOUNITARIO / (100 + T1.PORCENTAJEIVA) AS cImpuesto1,
	convert(decimal(15,2), T0.CANTIDADRECIBIDA * T0.PRECIOUNITARIO * (T1.PORCENTAJEIVA/100)) AS cImpuesto1,
	T1.PORCENTAJEIVA AS cPorcentajeImpuesto1,
	isnull(T0.RETENCIONISR, 0) as cPorcentajeRetencion1,
	isnull(T0.RETENCIONIVA, 0) as cPorcentajeRetencion2,
	dbo.fn_StdCentOper(T1.IDCENTROOPERATIVO) + case when T0.IDREFACCION <> 0 then 'REFA' else case when T0.IDMODELO <> 0 then 'ENUE' else 'GTOS' end end AS cCodigoAlmacen,
	convert(varchar,T0.IDCONRM) AS cReferencia, 
	isnull(rtrim(T2.DESCRIPCION) + ' ' + rtrim(T2.CODIGO),'') + isnull(rtrim(T3.NOMBRE) + ' ' + rtrim(T3.MARCA) + ' ' + rtrim(T3.DESCRIPCION),'') AS cObservaMov,
	convert(varchar, isnull(T0.IDMODELO,0) + isnull(T0.IDREFACCION,0)) AS cTextoExtra1,
	'' AS cTextoExtra2,
	'' AS cTextoExtra3,
	0 as cCostoEspecifico,
	0 AS cImporteExtra1,
	0 AS cImporteExtra2,
	'' as cSCMovto
from Score.ConRM T0
	inner join Score.RMPorTimbrar T1 on T0.IDRECEPCIONMERCANCIA = T1.IDRECEPCIONMERCANCIA
	left join Score.Refaccion T2 on T0.IDREFACCION = T2.IDREFACCION
	left join Score.Modelo T3 on T0.IDMODELO = T3.IDMODELO

Select NUMERO from Score.RMPorTimbrar

select * from [Score].[RequisicionPorImportar]