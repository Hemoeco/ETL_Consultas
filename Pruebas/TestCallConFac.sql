-- Profiler: 5531, 4581
Select top 100 con.* 
	from Score.Factura as f
	join Score.ConFac as con on con.FACTURASNUMERO = f.IDFACTURA

-- Profiler: 3005, 2689
Select top 100 con.* 
	from [serverScore].IT_Rentas_pruebas.dbo.OperFacturas as f
	join [serverScore].IT_Rentas_pruebas.dbo.OperConFac as con on con.FACTURASNUMERO = f.IDFACTURA

-- Server 'serverScore' is not configured for RPC.
EXECUTE ('Select * from test_ConFac') AT [serverScore]