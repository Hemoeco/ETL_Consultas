#Hemoeco Renta (2025)

if (-not $env:ETLUsuario) {
    Write-Error "Por favor configure la variable de entorno 'ETLUsuario'..."
    exit 1
}

# Validar si la variable de entorno sqlcmdPassword está definida
if (-not $env:ETLContrasenia) {
    Write-Error "Por favor configure la variable de entorno 'ETLContrasenia'..."
    exit 1
}

# requerido un argumento de entrada "prueba" o "prod"
$configuracion = $args[0]
if (-not $configuracion -or ($configuracion -ne "prueba" -and $configuracion -ne "prod")) {
    Write-Error "Por favor proporcione un argumento válido: 'prueba' o 'prod'."
    exit 1
}


# Configuración de conexión
$Env:sqlcmdServer="192.168.111.13\COMPAC" # servidor de produccion
# $Env:sqlcmdServer=".\SQLExpress" # servidor local, cambiar si es necesario"

# la base de datos a utilizar debe existir, crearla con un usuario que tenga permisos adecuados,
# después correr el script ConfigDB.sql para crear los servidores relacionados. Opcionalmente, puede
# correr ETL_Users.sql para crear un usuario de pruebas con permisos para correr todos estos scripts.
$Env:sqlcmdDbName="ETL_Prod_Cesar"

# copiar usuario y contraseña de la variable de entorno
$env:sqlcmdUser = $env:ETLUsuario
$env:sqlcmdPassword = $env:ETLContrasenia

#presentacion
[System.Console]::ForegroundColor = "Magenta"
Write-Host "-----------------------------------------------------------"
Write-Host "Iniciando el proceso de preparación de la base de datos..."
write-host ""
Write-Host "Servidor: $Env:sqlcmdServer"
Write-Host "Base de datos: $Env:sqlcmdDbName"
Write-Host "Usuario: $Env:sqlcmdUser"
Write-Host "-----------------------------------------------------------"

# Prompt user for confirmation key
$key = Read-Host "¿Continuar? (S/N)"

if ($key -ne "S" -and $key -ne "s") {
    Write-Host "Proceso cancelado por el usuario."
    exit 0
}

[System.Console]::ForegroundColor = "Green"

try {
    #funciones independientes 
    ./RunSqlScript.ps1 ../Functions/Fecha.sql
    ./RunSqlScript.ps1 ../Functions/fn_AdaptarDescripcionObservacion.sql
    ./RunSqlScript.ps1 ../Functions/fn_CalcularCostoEspecifico.sql
    ./RunSqlScript.ps1 ../Functions/fn_CalcularImporteExtra.sql
    ./RunSqlScript.ps1 ../Functions/fn_ConsultarCodigoProducto.sql
    ./RunSqlScript.ps1 ../Functions/fn_CrearCodigoProdPers.sql
    ./RunSqlScript.ps1 ../Functions/fn_FechaIT.sql
    ./RunSqlScript.ps1 ../Functions/fn_FechaITaETL.sql
    ./RunSqlScript.ps1 ../Functions/fn_IncluirAPartirDe.sql
    ./RunSqlScript.ps1 ../Functions/fn_ObtenerCodigoAlmacen.sql
    ./RunSqlScript.ps1 ../Functions/fn_ObtenerCodigoProducto.sql
    ./RunSqlScript.ps1 ../Functions/fn_PrimerPalabra.sql
    ./RunSqlScript.ps1 ../Functions/fn_split_string_to_column.sql
    ./RunSqlScript.ps1 ../Functions/fn_StdCentOper.sql

    #funcion dependiente de la tabla Debug (se crea en ConfigDB.sql, que a su vez se corre manualmente) 
    ./RunSqlScript.ps1 ../Functions/Dependent/fn_HemoecoDebug.sql
    ./RunSqlScript.ps1 ../Functions/Dependent/fn_NombreUnidadBase.sql

    #tablas base
    ./RunSqlScript.ps1 ../Views/$configuracion/TablasComercial.sql
    ./RunSqlScript.ps1 ../Views/$configuracion/TablasScore.sql

    #funciones dependientes de las tablas
    ./RunSqlScript.ps1 ../Functions/$configuracion/fn_ExisteProducto.sql
    # ./RunSqlScript.ps1 ../Functions/$configuracion/fn_GetIdConFacOriginalUnico.sql utilizar 'IdConFacOriginalUnico' en lugar de esta funcion

    ./RunSqlScript.ps1 ../Views/Documentos.sql
    ./RunSqlScript.ps1 ../Views/Movimientos.sql
    ./RunSqlScript.ps1 ../Views/Productos.sql

    # # Obtener lista de archivos .sql
    # $sqlFiles = Get-ChildItem -Path $scriptFolder -Filter *.sql

    # # Ejecutar cada script solo si contiene la palabra clave
    # foreach ($file in $sqlFiles) {
    #     $filePath = $file.FullName
    #     $fileContent = Get-Content -Path $filePath -Raw

    #     if ($fileContent -match $keyword) {
    #         Write-Host "Ejecutando $filePath..."

    #         $sqlCmd = "sqlcmd -S $serverInstance -d $database -U tu_usuario -P $env:sqlcmdPassword -i `"$filePath`""
    #         Invoke-Expression $sqlCmd

    #         Write-Host "Finalizado: $filePath"
    #     } else {
    #         Write-Host "Omitido: $filePath (No contiene '$keyword')"
    #     }
    # }
} catch {
    Write-Error "$_"
    exit 1
}

Write-Host "Proceso finalizado."