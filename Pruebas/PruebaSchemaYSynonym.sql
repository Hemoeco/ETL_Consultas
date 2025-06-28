print OBJECT_ID('cesar_conFacPers')

Create Synonym cesar_conFacPers for OperConFacPers
Drop Synonym cesar_conFacPers

go
Create schema [prueba_cesar];
go

Create Synonym [prueba_cesar].[cesar_conFacPers] for OperConFacPers
Drop Synonym [prueba_cesar].[cesar_conFacPers]

print OBJECT_ID('cesar_conFacPers')
print OBJECT_ID('[prueba_cesar].[cesar_conFacPers]')
