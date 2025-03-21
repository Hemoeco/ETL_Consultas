-- (2025) Hemeoco Renta 
-- creación de usuarios para ETL

-- Cesar
Use [etlPRUEBA]
go

Create Login [cesar.vargas] with password = ''
Create user [cesar.vargas] for login [cesar.vargas]
go
Alter role [db_backupoperator] Add Member [cesar.vargas]
Alter role [db_datareader] Add Member [cesar.vargas]
Alter role [db_datawriter] Add Member [cesar.vargas]
Alter role [db_ddladmin] Add Member [cesar.vargas]
-- Alter role [db_owner] Add Member [cesar.vargas]
go

Use [adhemoeco_prueba]
go

Create user [cesar.vargas] for login [cesar.vargas]
Alter role [db_datareader] Add Member [cesar.vargas]
Alter role [db_ddladmin] Add Member [cesar.vargas]

Use [ctHemoeco_Renta_SA_de_CV_2016]
go

Create user [cesar.vargas] for login [cesar.vargas]
Alter role [db_datareader] Add Member [cesar.vargas]
Alter role [db_ddladmin] Add Member [cesar.vargas]

Use [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata]
Create user [cesar.vargas] for login [cesar.vargas]
Alter role [db_datareader] Add Member [cesar.vargas]

Use [adHEMOECO_RENTA_SA_DE_CV_2018]
Create user [cesar.vargas] for login [cesar.vargas]
Alter role [db_datareader] Add Member [cesar.vargas]


-- Saúl
Create Login [Saul.Munoz] with password = ''
go

Create user [Saul.Munoz] for login [saul.munoz]

go
Alter role [db_backupoperator] Add Member [Saul.Munoz]
Alter role [db_datareader] Add Member [Saul.Munoz]
Alter role [db_datawriter] Add Member [Saul.Munoz]
Alter role [db_ddladmin] Add Member [Saul.Munoz]
-- Alter role [db_owner] Add Member [Saul.Munoz]
go

Use [adhemoeco_prueba]
go

Create user [Saul.Munoz] for login [saul.munoz]
Alter role [db_datareader] Add Member [Saul.Munoz]
Alter role [db_ddladmin] Add Member [Saul.Munoz]

Use [ctHemoeco_Renta_SA_de_CV_2016]
go

Create user [Saul.Munoz] for login [Saul.Munoz]
Alter role [db_datareader] Add Member [Saul.Munoz]
Alter role [db_ddladmin] Add Member [Saul.Munoz]

Use [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata]
Create user [Saul.Munoz] for login [Saul.Munoz]
Alter role [db_datareader] Add Member [Saul.Munoz]

-- Pruebas
-- Select top 10 * from Movimientos
-- Select top 10 * from Documentos

-- Dani Ruiz
Create Login [daniel.ruiz] with password = ''
go

Create user [daniel.ruiz] for login [daniel.ruiz]

go
Alter role [db_backupoperator] Add Member [daniel.ruiz]
Alter role [db_datareader] Add Member [daniel.ruiz]
Alter role [db_datawriter] Add Member [daniel.ruiz]
Alter role [db_ddladmin] Add Member [daniel.ruiz]
-- Alter role [db_owner] Add Member [daniel.ruiz]
go

Use [adhemoeco_prueba]
go

Create user [daniel.ruiz] for login [daniel.ruiz]
Alter role [db_datareader] Add Member [daniel.ruiz]
Alter role [db_ddladmin] Add Member [daniel.ruiz]

Use [ctHemoeco_Renta_SA_de_CV_2016]
go

Create user [daniel.ruiz] for login [daniel.ruiz]
Alter role [db_datareader] Add Member [daniel.ruiz]
Alter role [db_ddladmin] Add Member [daniel.ruiz]

Use [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata]
Create user [daniel.ruiz] for login [daniel.ruiz]
Alter role [db_datareader] Add Member [daniel.ruiz]

Use [adHEMOECO_RENTA_SA_DE_CV_2018]
Create user [daniel.ruiz] for login [daniel.ruiz]
Alter role [db_datareader] Add Member [daniel.ruiz]

-- Dani Hernández
Create Login [daniel.hernandez] with password = ''
go

Create user [daniel.hernandez] for login [daniel.hernandez]

go
Alter role [db_backupoperator] Add Member [daniel.hernandez]
Alter role [db_datareader] Add Member [daniel.hernandez]
Alter role [db_datawriter] Add Member [daniel.hernandez]
Alter role [db_ddladmin] Add Member [daniel.hernandez]
-- Alter role [db_owner] Add Member [daniel.hernandez]
go

Use [adhemoeco_prueba]
go

Create user [daniel.hernandez] for login [daniel.hernandez]
Alter role [db_datareader] Add Member [daniel.hernandez]
Alter role [db_ddladmin] Add Member [daniel.hernandez]

Use [ctHemoeco_Renta_SA_de_CV_2016]
go

Create user [daniel.hernandez] for login [daniel.hernandez]
Alter role [db_datareader] Add Member [daniel.hernandez]
Alter role [db_ddladmin] Add Member [daniel.hernandez]

Use [document_273d0425-9e06-4275-a043-21fe8d6f23e4_metadata]
Create user [daniel.hernandez] for login [daniel.hernandez]
Alter role [db_datareader] Add Member [daniel.hernandez]

Use [adHEMOECO_RENTA_SA_DE_CV_2018]
Create user [daniel.hernandez] for login [daniel.hernandez]
Alter role [db_datareader] Add Member [daniel.hernandez]
