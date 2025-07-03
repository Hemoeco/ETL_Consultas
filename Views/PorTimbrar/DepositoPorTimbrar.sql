/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener datos de depositos por timbrar
------------------------------------------------------- */
Create or alter view [Score].[DepositoPorTimbrar]
As
	with PagosDeposito as (select OP.DEPOSITOSNUMERO,
						OP.IDFORMAPAGO, OP.IDSUCURSAL, OP.CLIENTESNUMERO, OP.IDCUENTABANCOS,
						Sum(IIf(T2.METODODEPAGO='PUE', 1, 0)) as PUE,
						Convert(decimal(10,2), Sum((IIf(T2.Moneda like 'P%', 1, T2.TIPOCAMBIO) * T2.IVA * OFP.IMPORTE)/T2.TOTAL)) as IVA
					from Score.Pago OP
						inner join Score.FacturaPago OFP on OFP.PAGOSNUMERO = OP.NUMERO
						inner join Score.Factura T2 on OFP.FACTURASNUMERO = T2.IDFACTURA
					where T2.TOTAL <> 0
					group by OP.DEPOSITOSNUMERO, OP.CLIENTESNUMERO, OP.IDFORMAPAGO, OP.IDSUCURSAL, OP.IDCUENTABANCOS)
	Select OD.*,
		dbo.fn_FechaITaETL(OD.FECHA) AS FechaStr,
    	PCO.INICIALES,
		OP.IVA as IVAPago,
		OP.IDFORMAPAGO as IdFormaPago,
		CCB.CUENTABANCARIA,
		M0.CRUTACONTPAQ,
		OP.IDSUCURSAL as IdSucursalPago,
		OP.CLIENTESNUMERO as ClientesNumeroPago
	from Score.Deposito as OD
		join FechaIncluirAPartirDe as F on OD.FECHA >= F.FechaCorte
		INNER JOIN Score.ParaCentOper PCO with (nolock) ON OD.IDCENTROOPERATIVO = PCO.IDCENTROOPERATIVO
		inner join PagosDeposito as OP on OP.DEPOSITOSNUMERO = OD.IDDEPOSITO
		inner join Score.CuentaBanco as CCB with (nolock) on CCB.IDCUENTABANCOS = OP.IDCUENTABANCOS
		INNER JOIN Comercial.Parametro M0 on M0.CIDEMPRESA>0
	where OD.TIMBRAR='S'
		and not exists (select 1 from Comercial.Documento as M8 with (nolock) 
					where M8.CIDDOCUMENTODE=9 and M8.CSERIEDOCUMENTO=Concat('P', rtrim(PCO.INICIALES)) and M8.cfolio = OD.IDDEPOSITO)-- Incluido en 
		and '10' <> case when OP.PUE>0 or OD.IMPORTE * IIf(OD.Moneda like 'P%', 1, OD.TIPOCAMBIO) < 10 then '10' else 'PPD' end  -- se comenta para poder contabilizar los pagos PUE
		and OD.IDDEPOSITO > 405000 -- Solo pruebas
GO

-- test
-- Select * from Score.DepositoPorTimbrar