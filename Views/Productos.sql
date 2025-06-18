/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para la consulta de importación de producto
-- lee los documentos de Score para importarlos a Comercial
------------------------------------------------------- */

CREATE or ALTER VIEW [dbo].[Productos] AS
with Refaccion as (
	SELECT 'REF' + convert(varchar,IDREFACCION) AS cCodigoProducto,
		'VENTA REFACCION' AS cNombreProducto,
		1 AS cTipoProducto,
		1 AS cMetodoCosteo,
		1 AS cControlExistencia, 
		'PIEZA' AS cNombreUnidadBase,
		0 AS cImpuesto1,
		CODSAT as cClaveSAT
	FROM Score.RefaccionConCodSAT

	-- REF41693 aparece adicional después de los cambios (estaba comparandose con IT_Rentas)
	-- where IDREFACCION = 41693
	-- Select cTipoProducto, cNombreProducto, cClaveSAT from Comercial.Producto where cCodigoProducto = 'REF41693'
),
Linea as (
	SELECT 'MOD' + convert(varchar,IDLINEA) AS cCodigoProducto,
		'VENTA EQUIPO' AS cNombreProducto,
		1 AS cTipoProducto,
		1 AS cMetodoCosteo,
		1 AS cControlExistencia, 
		'PIEZA' AS cNombreUnidadBase,
		0 AS cImpuesto1,
		CODSAT as cClaveSAT
	FROM Score.LineaConCodSAT
	-- MOD205 aparece adicional al original
	-- where IDLINEA = 205
	-- Select cTipoProducto, cNombreProducto, cClaveSAT from Comercial.Producto where cCodigoProducto = 'MOD205'
	-- La diferencia está en el código SAT: '1010101' vs '01010101'
),
Servicio as (
	SELECT 'SRV' AS cCodigoProducto,
		'SERVICIO' AS cNombreProducto,
		3 AS cTipoProducto,
		7 AS cMetodoCosteo,
		1 AS cControlExistencia, 
		'SERVICIO' AS cNombreUnidadBase,
		0 AS cImpuesto1,
		'72101500' as cClaveSAT
),
Renta as (
	SELECT 'REN' AS cCodigoProducto,
		'RENTA' AS cNombreProducto,
		3 AS cTipoProducto,
		7 AS cMetodoCosteo,
		1 AS cControlExistencia,
		'DIA(S)' AS cNombreUnidadBase,
		0 AS cImpuesto1,
		'72141700' as cClaveSAT
),
RentaMes as (
	SELECT 'MREN' AS cCodigoProducto, -- usado en XML_ETIQUETA2 para utilizar código mes
		'RENTA' AS cNombreProducto,
		3 AS cTipoProducto,
		7 AS cMetodoCosteo,
		1 AS cControlExistencia,
		'MES(ES)' AS cNombreUnidadBase, -- todo: validar este campo
		--N'MON - Mes' as ClaveUnidadSAT,
		0 AS cImpuesto1,
		'72141700' as cClaveSAT
),
ConFacPersCodigoProd as (
	SELECT Id, 
		pers.IdConFac as IdConFac, 
		C_ClaveProdServ,
		C_ClaveUnidad,
		MTIPO,
		pers.Descripcion,
		dbo.fn_PrimerPalabra(pers.Descripcion) AS PrimerPalabraDesc,
		case
			when MTIPO in ('Refacción', 'Venta Nuevo', 'Venta Usado') then 1 -- = Producto
			else 3 -- = Servicio
		end as tipoProducto
		-- test , dbo.fn_ConsultarCodigoProducto(pers.Descripcion, pers.C_ClaveProdServ, pers.C_ClaveUnidad) as p
		from Score.ConFacPersPorTimbrar as pers
			join Score.ConFacPorTimbrar as cft on cft.IDCONFAC = pers.IdConFac
		where dbo.fn_ConsultarCodigoProducto(pers.Descripcion, pers.C_ClaveProdServ, pers.C_ClaveUnidad) is null
), -- select * from ConFacPersCodigoProd -- test
ProdPersAImportar as (
	SELECT dbo.fn_CrearCodigoProdPers(MTIPO, C_ClaveProdServ, C_ClaveUnidad, Descripcion) AS cCodigoProducto,
		PrimerPalabraDesc AS cNombreProducto,
		tipoProducto AS cTipoProducto,
		Iif(tipoProducto = 1, 1, 7) AS cMetodoCosteo, -- Si es producto, el método de costeo es 1, si es servicio, el método de costeo es 7
		1 AS cControlExistencia,
		dbo.fn_GetNombreUnidadBase(C_ClaveUnidad) AS cNombreUnidadBase,
		0 AS cImpuesto1,
		C_ClaveProdServ AS cClaveSAT
		from ConFacPersCodigoProd as pers
), -- Select * from ProdPersAImportar -- test,
TodosLosProductos as (
	Select * from Refaccion
	UNION ALL
	Select * from Linea
	UNION ALL
	Select * from Servicio
	UNION ALL
	Select * from Renta
	UNION ALL
	Select * from RentaMes
	UNION ALL
	Select * from ProdPersAImportar
	)
Select t.* from TodosLosProductos as t
	-- *****
	-- Profiler CPU = 62, Reads = 2, Writes = 0, Duration = 109 ms
	where not exists (Select 1 from dbo.fn_ExisteProducto(
		t.cCodigoProducto,
		t.cTipoProducto,
		t.cNombreProducto,
		t.cClaveSAT
	))

	-- *****
	-- Presentamos otras alternativas que se consideraron para esta consulta
	-- *****
	-- Profiler CPU = 310, Reads = 2, Writes = 0, Duration = 74 ms
	--	left join Comercial.Producto as p on T.cCodigoProducto = p.cCodigoProducto
	--		and t.cTipoProducto = p.cTipoProducto 
	--		and t.cNombreProducto = p.cNombreProducto 
	-- 		and t.cClaveSAT = p.cClaveSAT
	--   where p.cidproducto is null
	-- *****
	-- Profiler CPU = 5813, Reads = 18, Writes = 0, Duration = 125377 ms
	-- where dbo.fn_ExisteProducto(
	-- 		t.cCodigoProducto,
	-- 		t.cTipoProducto,
	-- 		t.cNombreProducto,
	-- 		t.cClaveSAT
	-- 	) = 0
	-- *****
	-- Profiler CPU = 47, Reads = 2, Writes = 0, Duration = 110 ms
	-- where not exists (Select 1 from Comercial.Producto as p
	-- 	where t.cCodigoProducto = p.cCodigoProducto
	-- 		and t.cTipoProducto = p.cTipoProducto 
	-- 		and t.cNombreProducto = p.cNombreProducto 
	-- 		and t.cClaveSAT = p.cClaveSAT)
	-- *****
GO

-- Test
-- Select * from Comercial.Producto where cCodigoProducto = 'REF41693'
-- -- exec debug.sp_EnableHemoecoDebug
-- -- exec debug.sp_DisableHemoecoDebug
-- Select * from Productos order by cCodigoProducto
-- Select top 10 * from Productos