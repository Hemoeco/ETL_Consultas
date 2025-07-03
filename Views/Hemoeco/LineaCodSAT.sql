/* ----------------------------------
-- Hemoeco Renta (2025)
--
-- Linea para importar a Comercial
 ----------------------------------*/

Create or alter view [Score].[LineaConCodSAT]
As
	SELECT IDLINEA, rtrim(CODSAT) as CODSAT
	FROM Score.Linea
	WHERE CODSAT is not null
GO

