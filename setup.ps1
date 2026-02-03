Write-Host "Levantando contenedores con Docker Compose (build incluido)"
docker-compose up -d --build

Write-Host "Esperando 30 segundos para que los servicios inicien..."
Start-Sleep -Seconds 30

Write-Host "Creando usuario administrador (admin/admin)"
docker-compose exec -T superset superset fab create-admin --username admin --firstname Superset --lastname Admin --email admin@superset.com --password admin

Write-Host "Actualizando base de datos de Superset (db upgrade)..."
docker-compose exec -T superset superset db upgrade

Write-Host "Inicializando roles y permisos"
docker-compose exec -T superset superset init

Write-Host "---------------------------------------------------"
Write-Host "¡Superset está listo!" -ForegroundColor Cyan
Write-Host "Accede en: http://localhost:8088"
Write-Host "Usuario: admin"
Write-Host "Contraseña: admin"
Write-Host "---------------------------------------------------"

Write-Host "Para conectar manualmente a SQL Server desde Superset, en Settings -> Databases -> +Database"
Write-Host "Usa un SQLALCHEMY URI en este formato (no pegues credenciales en ficheros públicos):"
Write-Host "mssql+pymssql://<DB_USER>:<DB_PASS>@<DB_HOST>:1433/<DB_NAME>"
Write-Host "Ejemplo (sin credenciales): mssql+pymssql://user:pass@172.18.0.95:1433/ACEDHA_NetCore"
Write-Host ""
Write-Host "Si tu SQL Server está en tu máquina local y usas Docker Desktop, prueba host: host.docker.internal"
Write-Host "Prueba a conectarte a: mssql+pymssql://acedhaasv:5TwK-Hjp%3A%3BhSxP%5C5m%7Bb@172.18.0.95:1433/ACEDHA_NetCore"