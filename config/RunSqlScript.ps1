# Hemoeco Renta (2025)

try {
    # sqlcmd Utility
    # https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver16

    # Opciones sqlcmd: sqlcmd /? y https://stackoverflow.com/questions/5418690/return-value-of-sqlcmd
    # option "-f 65001" = Code page UTF-8 code pages: 
    Write-Host $args
    # sqlcmd -i""$args"" -b -m1 -f 65001
    # Invoke-Expression "sqlcmd -i `"$args`" -b -m1 -f 65001" -ErrorAction Stop

    sqlcmd -i""$args"" -b -m1 -f 65001

    if ($LASTEXITCODE -ne 0) {
        throw "Falla en el script: $args"
    }
}
catch {
    throw "Falla en el script: $args"
}
