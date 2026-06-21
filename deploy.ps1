#!/usr/bin/env powershell
# Twenty CRM Deployment Automation Script
# Uso: .\deploy.ps1 -Action [deploy|clean|logs|stop|status]

param(
    [ValidateSet("deploy", "clean", "logs", "stop", "status", "help")]
    [string]$Action = "help"
)

$projectPath = "C:\Users\kwide\twenty-local"
$containerPrefix = "twenty"

# Colores para output
$colors = @{
    "success" = "Green"
    "error"   = "Red"
    "warning" = "Yellow"
    "info"    = "Cyan"
    "debug"   = "Gray"
}

function Write-Log {
    param([string]$Message, [string]$Level = "info")
    $symbol = @{
        "success" = "✅"
        "error"   = "❌"
        "warning" = "⚠️"
        "info"    = "ℹ️"
        "debug"   = "🔍"
    }
    Write-Host "$($symbol[$Level]) $Message" -ForegroundColor $colors[$Level]
}

function Test-DockerRunning {
    try {
        $null = docker ps 2>&1
        return $true
    } catch {
        return $false
    }
}

function Test-EnvFile {
    $envPath = Join-Path $projectPath ".env"
    if (-Not (Test-Path $envPath)) {
        Write-Log "Archivo .env no encontrado en $projectPath" "error"
        return $false
    }

    # Verificar variables críticas
    $requiredVars = @("PG_DATABASE_USER", "PG_DATABASE_PASSWORD", "PG_DATABASE_HOST", "PG_DATABASE_PORT")
    $envContent = Get-Content $envPath
    
    foreach ($var in $requiredVars) {
        if (-Not ($envContent -match "^$var=")) {
            Write-Log "Variable crítica '$var' no encontrada o comentada en .env" "warning"
            return $false
        }
    }
    
    return $true
}

function Deploy {
    Write-Log "Iniciando despliegue de Twenty CRM..." "info"
    Write-Log "Ruta del proyecto: $projectPath" "debug"
    
    # Verificar Docker
    if (-Not (Test-DockerRunning)) {
        Write-Log "Docker no está ejecutándose. Inicia Docker Desktop e intenta de nuevo." "error"
        exit 1
    }
    Write-Log "Docker está ejecutándose" "success"
    
    # Verificar .env
    if (-Not (Test-EnvFile)) {
        Write-Log "Verifica tu archivo .env - variables críticas faltantes o comentadas" "error"
        Write-Log "Variables necesarias: PG_DATABASE_USER, PG_DATABASE_PASSWORD, PG_DATABASE_HOST, PG_DATABASE_PORT" "info"
        exit 1
    }
    Write-Log "Archivo .env verificado correctamente" "success"
    
    # Cambiar directorio
    Push-Location $projectPath
    
    try {
        # Limpiar contenedores viejos
        Write-Log "Verificando contenedores viejos..." "info"
        $oldContainers = docker ps -a --filter "name=$containerPrefix" --format "{{.Names}}"
        if ($oldContainers) {
            Write-Log "Eliminando contenedores anteriores..." "warning"
            docker compose down -v 2>&1 | Select-String "removed|Removing" | ForEach-Object { Write-Log $_ "debug" }
            Start-Sleep -Seconds 2
        }
        
        # Levantar servicios
        Write-Log "Levantando servicios con 'docker compose up'..." "info"
        docker compose up -d --pull always
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Error al levantar los servicios" "error"
            exit 1
        }
        
        Write-Log "Esperando a que los servicios se inicialicen..." "info"
        $maxWait = 120  # 2 minutos
        $elapsed = 0
        $healthy = $false
        
        while ($elapsed -lt $maxWait) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            
            $psOutput = docker compose ps --format "table {{.Names}}\t{{.Status}}"
            Write-Log "[$elapsed/$maxWait] Verificando estado..." "debug"
            
            # Contar contenedores healthy
            $healthyCount = $psOutput | Select-String "Healthy" | Measure-Object | Select-Object -ExpandProperty Count
            
            if ($healthyCount -ge 3) {
                $healthy = $true
                break
            }
        }
        
        # Mostrar estado final
        Write-Log "Estado final de los servicios:" "info"
        docker compose ps
        
        if ($healthy) {
            Write-Log "Despliegue completado exitosamente!" "success"
            Write-Log "Accede a la aplicación en: http://localhost:3000" "success"
            Write-Log "Abriendo navegador..." "info"
            Start-Process "http://localhost:3000"
        } else {
            Write-Log "Los servicios se están inicializando (puede tomar más tiempo)" "warning"
            Write-Log "Revisa los logs con: .\deploy.ps1 -Action logs" "info"
        }
    }
    catch {
        Write-Log "Error durante el despliegue: $_" "error"
        exit 1
    }
    finally {
        Pop-Location
    }
}

function Clean {
    Write-Log "Iniciando limpieza completa..." "warning"
    
    if (-Not (Test-DockerRunning)) {
        Write-Log "Docker no está ejecutándose" "error"
        exit 1
    }
    
    Push-Location $projectPath
    
    try {
        Write-Log "Deteniendo todos los contenedores..." "info"
        docker compose down -v
        
        Write-Log "Limpiando volúmenes huérfanos..." "info"
        docker volume prune -f
        
        Write-Log "Limpieza completada exitosamente" "success"
        Write-Log "Próximo despliegue: .\deploy.ps1 -Action deploy" "info"
    }
    catch {
        Write-Log "Error durante la limpieza: $_" "error"
        exit 1
    }
    finally {
        Pop-Location
    }
}

function ShowLogs {
    if (-Not (Test-DockerRunning)) {
        Write-Log "Docker no está ejecutándose" "error"
        exit 1
    }
    
    Write-Log "Mostrando logs del servidor Twenty CRM..." "info"
    Write-Log "Presiona Ctrl+C para detener" "info"
    
    Push-Location $projectPath
    try {
        docker logs -f twenty-server-1
    }
    catch {
        Write-Log "Error al obtener logs: $_" "error"
    }
    finally {
        Pop-Location
    }
}

function Stop {
    Write-Log "Deteniendo servicios..." "info"
    
    if (-Not (Test-DockerRunning)) {
        Write-Log "Docker no está ejecutándose" "error"
        exit 1
    }
    
    Push-Location $projectPath
    try {
        docker compose stop
        Write-Log "Servicios detenidos correctamente" "success"
        Write-Log "Para reanudar: .\deploy.ps1 -Action deploy" "info"
    }
    catch {
        Write-Log "Error al detener servicios: $_" "error"
        exit 1
    }
    finally {
        Pop-Location
    }
}

function Status {
    if (-Not (Test-DockerRunning)) {
        Write-Log "Docker no está ejecutándose" "error"
        exit 1
    }
    
    Write-Log "Estado actual de los servicios:" "info"
    
    Push-Location $projectPath
    try {
        Write-Host ""
        docker compose ps
        Write-Host ""
        
        Write-Log "Estadísticas de recursos:" "info"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
        
        Write-Host ""
        Write-Log "Volúmenes del proyecto:" "info"
        docker volume ls --filter "name=$containerPrefix"
    }
    catch {
        Write-Log "Error al obtener estado: $_" "error"
    }
    finally {
        Pop-Location
    }
}

function ShowHelp {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           Twenty CRM - Docker Deployment Script                ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "COMANDOS DISPONIBLES:" -ForegroundColor Green
    Write-Host ""
    Write-Host "  deploy    - Desplegar Twenty CRM (limpiar + levantar servicios)" -ForegroundColor Yellow
    Write-Host "  clean     - Limpiar contenedores y volúmenes completamente" -ForegroundColor Yellow
    Write-Host "  logs      - Ver logs en vivo del servidor" -ForegroundColor Yellow
    Write-Host "  stop      - Detener los servicios (sin eliminar datos)" -ForegroundColor Yellow
    Write-Host "  status    - Ver estado actual de los servicios" -ForegroundColor Yellow
    Write-Host "  help      - Mostrar esta ayuda" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "EJEMPLOS DE USO:" -ForegroundColor Green
    Write-Host ""
    Write-Host "  # Desplegar la aplicación" -ForegroundColor Gray
    Write-Host "  .\deploy.ps1 -Action deploy" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Ver logs en tiempo real" -ForegroundColor Gray
    Write-Host "  .\deploy.ps1 -Action logs" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Verificar estado" -ForegroundColor Gray
    Write-Host "  .\deploy.ps1 -Action status" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Limpiar todo (cuidado: borra la BD)" -ForegroundColor Gray
    Write-Host "  .\deploy.ps1 -Action clean" -ForegroundColor White
    Write-Host ""
    Write-Host "INFORMACIÓN DEL PROYECTO:" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Ruta: $projectPath" -ForegroundColor Gray
    Write-Host "  Aplicación: http://localhost:3000" -ForegroundColor Gray
    Write-Host ""
    Write-Host "NOTAS IMPORTANTES:" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  ⚠️  Asegúrate de que Docker Desktop está ejecutándose" -ForegroundColor Yellow
    Write-Host "  ⚠️  El archivo .env debe estar configurado correctamente" -ForegroundColor Yellow
    Write-Host "  ⚠️  Primera ejecución puede tomar 3-5 minutos" -ForegroundColor Yellow
    Write-Host "  ⚠️  'clean' elimina la base de datos - úsalo con cuidado" -ForegroundColor Yellow
    Write-Host ""
}

# Ejecutar acción
switch ($Action) {
    "deploy" { Deploy }
    "clean" { Clean }
    "logs" { ShowLogs }
    "stop" { Stop }
    "status" { Status }
    "help" { ShowHelp }
    default { ShowHelp }
}
