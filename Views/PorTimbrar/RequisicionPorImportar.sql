/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Vista para obtener requisiciones por importar
------------------------------------------------------- */
Create or alter view [Score].[RequisicionPorImportar]
As
	with FechaRec as (
		select IDREQUISICION, FECHARECIBIDA
		from Score.ConReq 
		group by IDREQUISICION, FECHARECIBIDA
	)
	Select T0.IDREQUISICION,
		dbo.fn_FechaITaETL(T4.FECHARECIBIDA) AS FechaRecibidaStr,
		RTrim(T1.INICIALES) as InicialesCentOper,
		T2.CCODIGOCONCEPTO as ComerciaCodigoConcepto,
		T0.IDSUCURSALORIGEN,
		T0.IDCENTROOPERATIVOORIGEN
	from Score.Requisicion as T0
		join FechaRec as T4 on T4.IDREQUISICION = T0.IDREQUISICION
		join FechaIncluirAPartirDe as F on T4.FECHARECIBIDA >= F.FechaCorte
		INNER JOIN Score.ParaCentOper T1 ON T0.IDCENTROOPERATIVOORIGEN = T1.IDCENTROOPERATIVO
		inner join Comercial.Concepto T2 on T2.CCODIGOCONCEPTO = 'REQ' + dbo.fn_StdCentOper(T0.IDCENTROOPERATIVOORIGEN)
	where T0.IDREQUISICION > 8492
		and not exists (select 1 from Comercial.Documento T3 
							where T3.CIDCONCEPTODOCUMENTO = T2.CIDCONCEPTODOCUMENTO 
							AND T3.CSERIEDOCUMENTO=rtrim(T1.INICIALES) 
							AND T3.cFolio = T0.IDREQUISICION)
		-- and 0 = 1 -- Solo pruebas
Go

-- Eliminar el view anterior, reemplazado con este
if (Object_Id('Score.RequisicionPorTimbrar') is not null)
	drop view Score.RequisicionPorTimbrar
