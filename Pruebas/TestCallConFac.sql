-- Profiler: 5531, 4581
Select top 100 con.* 
	from Score.Factura as f
	join Score.ConFac as con on con.FACTURASNUMERO = f.IDFACTURA

-- Profiler: 3005, 2689
Select top 100 con.* 
	from [serverScore].IT_Rentas_pruebas.dbo.OperFacturas as f
	join [serverScore].IT_Rentas_pruebas.dbo.OperConFac as con on con.FACTURASNUMERO = f.IDFACTURA

-- Create this view on Score DB server
Create or alter View test_ConFac
as
	Select top 100 con.* 
		from OperFacturas as f
		join OperConFac as con on con.FACTURASNUMERO = f.IDFACTURA
GO
grant select, view definition on dbo.test_ConFac to PUBLIC

-- 385, 349
-- Server 'serverScore' is not configured for RPC.
EXECUTE ('Select top 100 * from test_ConFac') AT [serverScore]
Select top 100 * from serverScore.IT_Rentas_pruebas.dbo.test_ConFac