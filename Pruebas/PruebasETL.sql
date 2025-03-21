-- Hemoeco Renta (2025)
--
-- Consultas de prueba para identificar datos en Etl y Comercial
-- --------------------------------------------------------------


Select * from Documentos

-- Identificar prod/serv en comercial para obtener clave prod/serv y unidad 
SELECT TOP (10) [CIDPRODUCTO]
      ,[CCODIGOPRODUCTO]
      ,[CNOMBREPRODUCTO]
      ,[CTIPOPRODUCTO]
      ,[CDESCRIPCIONPRODUCTO]
      ,[CIDUNIDADBASE]
    --   ,[CIMPUESTO1]
    --   ,[CIMPUESTO2]
    --   ,[CIMPUESTO3]
    --   ,[CTEXTOEXTRA1]
    --   ,[CTEXTOEXTRA2]
    --   ,[CTEXTOEXTRA3]
    --   ,[CPRECIO1]
      ,[CDESCCORTA]
      ,[CIDMONEDA]
      ,[CIDUNIXML]
      ,[CCLAVESAT]
      ,[CCANTIDADFISCAL]
  FROM [admProductos]
  where CCODIGOPRODUCTO like 'REN%'

  SELECT TOP (1000) [CIDUNIDAD]
      ,[CNOMBREUNIDAD]
      ,[CABREVIATURA]
      ,[CDESPLIEGUE]
      ,[CCLAVEINT]
      ,[CCLAVESAT]
  FROM [admUnidadesMedidaPeso]

-- Identificar producto MREN para borrarlo e importarlo como servicio
Select m.*, d.*, a.CNOMBREALMACEN
    from admMovimientos as m
        join admProductos as p on p.cidProducto = m.CIDPRODUCTO
        join admAlmacenes as a on a.CIDALMACEN = m.cidAlmacen
        join admDocumentos as d on d.CIDDOCUMENTO = m.CIDDOCUMENTO
    where p.CCODIGOPRODUCTO = 'MREN'

Select * from admProductos where CCODIGOPRODUCTO like 'REN%'

Select top 3 * from admProductos where CCODIGOPRODUCTO like 'MOD%'

--SELECT top 1 * FROM Movimientos
-- Select distinct MTIPO From [192.168.111.14].IT_Rentas_Pruebas.dbo.OperConFac
