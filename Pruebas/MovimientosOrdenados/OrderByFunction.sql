Create Function MovimientosOrdenados() returns table
as 
    return Select top 100 percent * from Movimientos order By cIdDocumento

Select * from MovimientosOrdenados()