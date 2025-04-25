-- Test results with 'fn_ObtenerCodigoProducto'
with MovNdC as (
    SELECT 'NC' + convert(varchar,T0.IDNOTASCREDITO) AS cIdDocumento,
        case when T0.TIPO='Anticipo' then 'ANT' else CASE WHEN T2.IDEQUIPONUEVO + T2.IDEQUIPOUSADO <> 0 THEN 'MOD' + convert(varchar, T2.IDLINEA)
            ELSE CASE WHEN T2.IDREFACCION <> 0 THEN 'REF' + convert(varchar, T2.IDREFACCION)
                ELSE CASE WHEN MTIPO = 'Renta Equipo' then 'REN' ELSE 'SRV' END
                END
        END END AS cCodigoProducto, 
--        case 
--            when T0.TIPO='Anticipo' then 'ANT'
--            when MTIPO='Anticipo' then 'SRV'
--            else
                 dbo.fn_ObtenerCodigoProducto(
                    MTIPO,
                    T2.IDEQUIPONUEVO,
                    T2.IDEQUIPOUSADO,
                    T2.DELAL,
                    T2.IDLINEA,
                    T2.IDREFACCION,
                    '')
--        end 
        AS cCodigoProducto2,
        T0.CANTIDAD AS cUnidades,
        T0.IMPORTE / T0.CANTIDAD AS cPrecio,
        (case when T1.DESGLOSARIVA='N' then 0 else case when T1.PORCENTAJEIVA=11 then 16 else T1.PORCENTAJEIVA end /100 end) * T0.CANTIDAD * T0.IMPORTE / T0.CANTIDAD AS cImpuesto1,
        case when T1.DESGLOSARIVA='N' then 0 else case when T1.PORCENTAJEIVA=11 then 16 else T1.PORCENTAJEIVA end end AS cPorcentajeImpuesto1,
        0 as cPorcentajeRetencion1,
        0 as cPorcentajeRetencion2,
        '0' + convert(varchar,T1.IDSUCURSAL) +
            case when T2.IDEQUIPONUEVO <> 0 then 'ENUE'
                else case when T2.IDREFACCION <> 0 then 'REFA'
                    else case when T2.IDEQUIPOUSADO <> 0 then 'EUSA'
                        else CASE WHEN MTIPO = 'Renta Equipo' then 'EREN' else 'OTR' end
                    end
                end
            end AS cCodigoAlmacen,
        --rtrim(T2.DELAL) AS cReferencia, 
        rtrim(SUBSTRING(T2.DELAL, 1, CHARINDEX('-', T2.DELAL))+' '+ substring(T2.DELAL, CHARINDEX('-', T2.DELAL)+1, LEN(T2.DELAL))) AS cReferencia, 
        case when T0.TIPO='Anticipo' then 'Anticipo' else rtrim(T2.DESCRIPCION) end AS cObservaMov,
        convert(varchar, T0.IDCONNOT) AS cTextoExtra1,
        '' AS cTextoExtra2,
        rtrim(T0.TIPO) AS cTextoExtra3,
        ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTONACIONAL, 0) + ISNULL(S4.COSTONACIONAL, 0) + T0.CANTIDAD * ISNULL(S6.COSTOUNITARIO, 0) AS cCostoEspecifico,
        (ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTONACIONAL, 0)) + ISNULL(S4.COSTONACIONAL, 0) * (isnull(S5.DEPRECIACIONCONTABLEPORCENTAJE,0) / 100) *
            CASE WHEN DATEDIFF(mm, dbo.fecha(ISNULL(S3.FECHAALTAHEMOECO, 0) + ISNULL(S4.FECHAALTARENTAHEMOECO, 0)), GETDATE()) - 1 <= 0 THEN 0
                WHEN DATEDIFF(mm, dbo.fecha(ISNULL(S3.FECHAALTAHEMOECO, 0) + ISNULL(S4.FECHAALTARENTAHEMOECO, 0)), GETDATE()) - 1 >= S5.DEPRECIACIONCONTABLEMESES THEN 1
                ELSE (DATEDIFF(mm, dbo.fecha(ISNULL(S3.FECHAALTAHEMOECO, 0) + ISNULL(S4.FECHAALTARENTAHEMOECO, 0)), GETDATE()) - 1) / S5.DEPRECIACIONCONTABLEMESES END AS cImporteExtra1,
        ISNULL(S2.COSTONACIONAL, 0) + ISNULL(S3.COSTONACIONAL, 0) + ISNULL(S4.COSTONACIONAL, 0) + T0.CANTIDAD * ISNULL(S6.COSTOUNITARIO, 0) AS cImporteExtra2,
        '' as cSCMovto
    FROM [192.168.111.14].IT_Rentas.dbo.OperConNot T0
        INNER JOIN [192.168.111.14].IT_Rentas.dbo.OperNotasCredito T1 ON T0.IDNOTASCREDITO = T1.IDNOTASCREDITO
        INNER JOIN [192.168.111.14].IT_Rentas.dbo.OperConFac T2 ON T0.IDCONFAC = T2.IDCONFAC
        LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposNuevos AS S2 ON T2.IDEQUIPONUEVO = S2.IDEQUIPO AND T2.DELAL = 'Venta'
        LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposRenta AS S3 ON T2.IDEQUIPORENTA = S3.IDEQUIPO AND T2.DELAL = 'Venta'
        LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataEquiposUsados AS S4 ON T2.IDEQUIPOUSADO = S4.IDEQUIPO AND T2.DELAL = 'Venta'
        LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.CataLineasSucursal AS S5 ON T2.IDLINEA = S5.IDLINEA AND T2.IDSUCURSAL = S5.IDSUCURSAL
        LEFT OUTER JOIN [192.168.111.14].IT_Rentas.dbo.OperOTRefacciones AS S6 ON T2.OTRLLAVEAUTONUMERICA = S6.IDOTREFACCIONES
    WHERE 
        T0.CANTIDAD > 0        
        -- and T0.Tipo <> 'Descuento'
        and T1.FECHA >= dbo.fn_FechaIncluirAPartirDe()
)
Select * from MovNdc 
    where cCodigoProducto <> cCodigoProducto2