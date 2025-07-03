/* ----------------------------------
-- Hemoeco Renta (2025)
--
-- Refaccion con código SAT
----------------------------------*/

-- Refacciones aptas para importar
Create or alter view [Score].[RefaccionConCodSAT]
As
	Select IDREFACCION, RTRIM(CODSAT) as CODSAT
	from Score.Refaccion
	where CODSAT is not null
GO

-- Test
-- Select * from Score.RefaccionConCodSAT