-- Pruebas para medir la eficiencia de diferentes combinaciones

-- Profiler duration: 1583, 735
SELECT top 100 IDFACTURA,
		IDSUCURSAL,
		IDCENTROOPERATIVO,
		CLIENTESNUMERO,
		FOLIO,
		IDEMPLEADO,
		FECHA,
		MONEDA,
		FECHAVENCIMIENTO,
		TOTAL,
		SALDO,
		FORMADEPAGO,
		METODODEPAGO,
		USOCFDI,
		OBRASNUMERO,
		TIPOCAMBIO,
		IVA,
		CANCELADA,
		FOLIO2,
		PROCESADA,
		OBSERVACIONES,
		ORDENDECOMPRA,
		XML_ETIQUETA2,
		XML_SUBTOTAL,
		XML_TOTAL,
		PORCENTAJEIVA
	FROM serverScore.IT_Rentas_pruebas.dbo.OperFacturas

-- profiler duration: 1626, 767
Select top 100 *
	FROM serverScore.IT_Rentas_pruebas.dbo.OperFacturas

--profiler: 2420, 499
SELECT *
    FROM Score.Factura
    WHERE TOTAL <> 0
        AND CANCELADA = 'N'
        AND FOLIO2 = ''
        AND PROCESADA = 'N'
        --  AND ISNULL(T4.FORMADEPAGO,'')<>''
        AND FECHA >= 80723 -- 2022-01-01 00:00:00.000
        --  AND (datediff(dd, dbo.Fecha(FECHA), GETDATE()) BETWEEN 1 AND 20 OR (datediff(dd, dbo.Fecha(FECHA), GETDATE()) = 0 AND PROCESADA = 'N')) -- Condicion para que Timbre Facturas al final del dia Sin Checkbox Timbrar

-- profiler: 1658, 502
-- Es un poco más rápido llamando la tabla remota directamente (a diferencia del view 'wraper') 
SELECT *
    FROM serverScore.IT_Rentas_pruebas.dbo.OperFacturas
    WHERE TOTAL <> 0
        AND CANCELADA = 'N'
        AND FOLIO2 = ''
        AND PROCESADA = 'N'
        --  AND ISNULL(T4.FORMADEPAGO,'')<>''
        AND FECHA >= 80723 -- 2022-01-01 00:00:00.000
