/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- Este script crea los esquemas para facilitar el uso de
-- las BD de Score y Comericial, de manera que se utilize
-- una notación estándarizada en las vistas finales, y se
-- mantenga la compatibilidad entre producción y desarrollo.
 ---------------------------------------------------- */
-- use ETL_pruebas

-- link external servers
DECLARE @SERVER_NAME varchar(64) = 'serverContabilidad';

-- Create linked server if not exists
IF NOT EXISTS (SELECT [name] FROM sys.servers WHERE [name] = @SERVER_NAME)
BEGIN
   -- Set up the linked server if it doesn't exist
   EXEC sp_addlinkedserver
      @server = @SERVER_NAME,
      @srvproduct = '',
      @provider = 'MSOLEDBSQL',
      @datasrc = '192.168.111.13\Compac',
      @catalog = 'adhemoeco_prueba'; -- prod: 'adHEMOECO_RENTA_SA_DE_CV_2018'; -- dev: 'adhemoeco_prueba'

   -- -- Setup login? login must be setup on a separate step...
   -- EXEC sp_addlinkedsrvlogin
   --    @rmtsrvname = @SERVER_NAME,
   --    @useself = 'true',
   -- @rmtuser = 'Contabilidad', -- User previously setup on Contabilidad, with read & write permissions to adHEMOECO_RENTA_SA_DE_CV_2018 & adHEMOECO2019_A_2020
   -- @rmtpassword = '';
END

GO

DECLARE @SERVER_NAME varchar(64) = 'serverScore';

-- Create linked server if not exists
IF NOT EXISTS (SELECT [name] FROM sys.servers WHERE [name] = @SERVER_NAME)
BEGIN
   -- Set up the linked server if it doesn't exist
   EXEC sp_addlinkedserver
      @server = @SERVER_NAME,
      @srvproduct = '',
      @provider = 'MSOLEDBSQL',
      @datasrc = '192.168.111.14\SQLExpress',
      @catalog = 'IT_Rentas_pruebas'; -- prod: 'IT_Rentas'; -- dev: 'IT_Rentas_pruebas'

   -- -- Setup login? login must be setup on a separate step...
   -- EXEC sp_addlinkedsrvlogin
   --    @rmtsrvname = @SERVER_NAME,
   --    @useself = 'true',
   -- @rmtuser = 'Score', -- User previously setup on Score, with read & write permissions to IT_Rentas
   -- @rmtpassword = '';
END

-- Enable RPC to be able to query data in Score server from ETL database (see Pruebas\TestCallConFac.sql)
EXEC sp_serveroption @server=@SERVER_NAME, @optname=N'RPC out', @optvalue=N'true'

-- print schema_id('Score')
if schema_id('Score') is null
begin
   execute('Create schema [Score] authorization dbo')
end
go

if schema_id('Comercial') is null
begin
   execute('Create schema [Comercial] authorization dbo')
end
go

