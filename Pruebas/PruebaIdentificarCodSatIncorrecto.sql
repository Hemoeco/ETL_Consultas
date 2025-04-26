-- Esta consulta sirve para identificar las refacciones con un CODSAT que no tiene equivalente en el catálogo de SAT.
Select IdRefaccion, CODSAT
    from CataRefacciones as r
        left join CataSAT_clave_prod_serv as cps on cps.C_ClaveProdServ = Cast(r.CODSAT as varchar)
    where CODSAT is not null and cps.Descripcion is null