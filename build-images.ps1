# ===========================================
# Script para construir imágenes Docker de microservicios
# ===========================================

param(
    [string]$Service = "all",
    [string]$Tag = "latest",
    [switch]$NoCache = $false,
    [switch]$Help = $false
)

# Función para mostrar ayuda
function Show-Help {
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "Script de construcción de imágenes Docker" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso:" -ForegroundColor Yellow
    Write-Host "  .\build-images.ps1 [SERVICIO] [TAG] [OPCIONES]" -ForegroundColor White
    Write-Host ""
    Write-Host "Servicios disponibles:" -ForegroundColor Yellow
    Write-Host "  all                    - Construir todas las imágenes (por defecto)" -ForegroundColor White
    Write-Host "  users-api              - API de usuarios (Spring Boot)" -ForegroundColor White
    Write-Host "  auth-api               - API de autenticación (Go)" -ForegroundColor White
    Write-Host "  todos-api              - API de tareas (Node.js)" -ForegroundColor White
    Write-Host "  log-processor          - Procesador de logs (Python)" -ForegroundColor White
    Write-Host "  frontend               - Frontend (Vue.js)" -ForegroundColor White
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "  -Tag <tag>             - Etiqueta para las imágenes (por defecto: latest)" -ForegroundColor White
    Write-Host "  -NoCache               - Construir sin usar caché de Docker" -ForegroundColor White
    Write-Host "  -Help                  - Mostrar esta ayuda" -ForegroundColor White
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Yellow
    Write-Host "  .\build-images.ps1" -ForegroundColor White
    Write-Host "  .\build-images.ps1 users-api" -ForegroundColor White
    Write-Host "  .\build-images.ps1 all v1.0.0" -ForegroundColor White
    Write-Host "  .\build-images.ps1 auth-api latest -NoCache" -ForegroundColor White
}

# Función para construir una imagen
function Build-Image {
    param(
        [string]$ServiceName,
        [string]$ContextPath,
        [string]$ImageTag
    )
    
    Write-Host "===========================================" -ForegroundColor Green
    Write-Host "Construyendo imagen: $ServiceName" -ForegroundColor Green
    Write-Host "Contexto: $ContextPath" -ForegroundColor Green
    Write-Host "Tag: $ImageTag" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Green
    
    $buildArgs = @("build", "-t", "microservices-$ServiceName`:$ImageTag", $ContextPath)
    
    if ($NoCache) {
        $buildArgs += "--no-cache"
    }
    
    try {
        $result = & docker @buildArgs 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Imagen construida exitosamente: microservices-$ServiceName`:$ImageTag" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Error al construir la imagen: $ServiceName" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Error al ejecutar Docker: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Función para verificar si Docker está disponible
function Test-DockerAvailable {
    try {
        $null = & docker --version 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# Función para listar imágenes construidas
function Show-BuiltImages {
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "Imágenes construidas:" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    
    $images = & docker images --filter "reference=microservices-*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    Write-Host $images -ForegroundColor White
}

# ===========================================
# CONFIGURACIÓN DE SERVICIOS
# ===========================================

$services = @{
    "users-api" = @{
        "context" = "./users-api"
        "description" = "API de usuarios (Spring Boot)"
    }
    "auth-api" = @{
        "context" = "./auth-api"
        "description" = "API de autenticación (Go)"
    }
    "todos-api" = @{
        "context" = "./todos-api"
        "description" = "API de tareas (Node.js)"
    }
    "log-processor" = @{
        "context" = "./log-message-processor"
        "description" = "Procesador de logs (Python)"
    }
    "frontend" = @{
        "context" = "./frontend"
        "description" = "Frontend (Vue.js)"
    }
}

# ===========================================
# VALIDACIONES
# ===========================================

if ($Help) {
    Show-Help
    exit 0
}

# Verificar si Docker está disponible
if (-not (Test-DockerAvailable)) {
    Write-Host "❌ Docker no está disponible o no está instalado." -ForegroundColor Red
    Write-Host "Por favor, instala Docker Desktop y asegúrate de que esté ejecutándose." -ForegroundColor Red
    exit 1
}

# Verificar si el directorio del proyecto existe
if (-not (Test-Path ".")) {
    Write-Host "❌ No se encontró el directorio del proyecto." -ForegroundColor Red
    Write-Host "Asegúrate de ejecutar este script desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

# ===========================================
# CONSTRUCCIÓN DE IMÁGENES
# ===========================================

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Iniciando construcción de imágenes Docker" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Servicio: $Service" -ForegroundColor White
Write-Host "Tag: $Tag" -ForegroundColor White
Write-Host "No Cache: $NoCache" -ForegroundColor White
Write-Host "===========================================" -ForegroundColor Cyan

$successCount = 0
$totalCount = 0

if ($Service -eq "all") {
    # Construir todas las imágenes
    foreach ($serviceName in $services.Keys) {
        $totalCount++
        $contextPath = $services[$serviceName].context
        
        # Verificar que el directorio del servicio existe
        if (-not (Test-Path $contextPath)) {
            Write-Host "⚠️  Advertencia: No se encontró el directorio $contextPath" -ForegroundColor Yellow
            continue
        }
        
        if (Build-Image -ServiceName $serviceName -ContextPath $contextPath -ImageTag $Tag) {
            $successCount++
        }
    }
} else {
    # Construir un servicio específico
    if ($services.ContainsKey($Service)) {
        $totalCount = 1
        $contextPath = $services[$Service].context
        
        if (-not (Test-Path $contextPath)) {
            Write-Host "❌ Error: No se encontró el directorio $contextPath" -ForegroundColor Red
            exit 1
        }
        
        if (Build-Image -ServiceName $Service -ContextPath $contextPath -ImageTag $Tag) {
            $successCount++
        }
    } else {
        Write-Host "❌ Error: Servicio '$Service' no reconocido." -ForegroundColor Red
        Write-Host "Servicios disponibles: $($services.Keys -join ', ')" -ForegroundColor Yellow
        exit 1
    }
}

# ===========================================
# RESUMEN FINAL
# ===========================================

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Resumen de construcción" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Imágenes construidas exitosamente: $successCount de $totalCount" -ForegroundColor White

if ($successCount -eq $totalCount) {
    Write-Host "✅ Todas las imágenes se construyeron correctamente" -ForegroundColor Green
} else {
    Write-Host "⚠️  Algunas imágenes fallaron en la construcción" -ForegroundColor Yellow
}

# Mostrar imágenes construidas
Show-BuiltImages

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Construcción completada" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

Write-Host "===========================================" -ForegroundColor Cyan