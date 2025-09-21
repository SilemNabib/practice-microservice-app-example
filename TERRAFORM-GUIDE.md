# 🚀 GUÍA COMPLETA DE TERRAFORM - MICROSERVICES

## 📋 ÍNDICE
1. [Prerequisitos](#prerequisitos)
2. [Configuración Inicial](#configuración-inicial)
3. [Variables a Configurar](#variables-a-configurar)
4. [Comandos Paso a Paso](#comandos-paso-a-paso)
5. [Troubleshooting](#troubleshooting)
6. [Conceptos Aprendidos](#conceptos-aprendidos)
7. [Próximos Pasos](#próximos-pasos)

---

## 🔧 PREREQUISITOS

### **Software Requerido:**
- ✅ **Terraform** >= 1.0
- ✅ **Docker** (Docker Desktop en Windows/macOS, o Colima en macOS)
- ✅ **Git** (para versionado)

### **Instalación de Terraform:**

#### **macOS:**
```bash
# Opción 1: Homebrew (Recomendado)
brew install terraform

# Opción 2: Descarga directa
# Descargar desde: https://www.terraform.io/downloads.html
# Mover a /usr/local/bin/terraform
```

#### **Windows:**
```powershell
# Opción 1: Chocolatey (Recomendado)
choco install terraform

# Opción 2: Scoop
scoop install terraform

# Opción 3: Descarga directa
# Descargar desde: https://www.terraform.io/downloads.html
# Agregar al PATH de Windows
```

#### **Verificar instalación:**
```bash
# macOS/Linux
terraform version

# Windows (PowerShell/CMD)
terraform version
```

### **Verificar Docker:**

#### **macOS:**
```bash
# Docker Desktop
docker --version
docker ps

# Colima (alternativa a Docker Desktop)
colima status
docker --version
docker ps
```

#### **Windows:**
```powershell
# Docker Desktop
docker --version
docker ps

# Verificar que Docker Desktop esté corriendo
# (Icono en la bandeja del sistema)
```

---

## ⚙️ CONFIGURACIÓN INICIAL

### **1. Configurar Variables de Entorno:**
```bash
# El script setup-env.sh carga las variables automáticamente
# Pero si quieres verificar manualmente:
source .env.local

# Verificar que se cargaron
echo $TF_VAR_docker_host
```

---

## 🔑 VARIABLES A CONFIGURAR

### **🎯 SISTEMA: Variables de Entorno**

**¡No más editar archivos de código!** Todo se configura con variables de entorno.


**El script `setup-env.sh` hace TODO automáticamente:**
- ✅ Detecta tu configuración de Docker (Colima o Docker Desktop)
- ✅ Configura todas las variables de entorno
- ✅ Crea la red Docker si no existe
- ✅ Verifica que todo funciona
- ✅ Muestra resumen de configuración

### **Opción A: Configuración Automática (Recomendado)**
```bash
# Ejecutar script automático (detecta TODO)
./setup-env.sh

# El script hace:
# 1. Detecta Docker host automáticamente
# 2. Crea archivo .env.local personalizado
# 3. Configura variables de entorno
# 4. Crea red Docker si no existe
# 5. Verifica conexión con Docker
# 6. Muestra resumen de configuración
```

### **Opción B: Configuración Manual (Si prefieres control total)**
```bash
# Copiar template
cp env.template .env.local

# Editar variables (cambiar USERNAME por tu usuario)
nano .env.local

# Cargar variables
source .env.local
```

### **Variables principales que puedes cambiar:**

#### **macOS/Linux:**
```bash
# Docker Host (detectado automáticamente por el script)
export TF_VAR_docker_host="unix:///Users/USERNAME/.colima/docker.sock"  # Colima
# o
export TF_VAR_docker_host="unix:///var/run/docker.sock"                   # Docker Desktop

# Network Subnet (cambiar si hay conflicto)
export TF_VAR_docker_network_subnet="192.168.100.0/24"

# Redis Password (cambiar por seguridad)
export TF_VAR_redis_password="mi-password-segura"

# Redis Port (cambiar si está ocupado)
export TF_VAR_redis_port="6379"

# Redis Version (opcional)
export TF_VAR_redis_version="7.0-alpine"

# Redis Memory Configuration (opcional)
export TF_VAR_redis_memory_limit="256mb"
export TF_VAR_redis_memory_policy="allkeys-lru"

# Cache TTL Configuration (opcional)
export TF_VAR_cache_ttl_default="300"
export TF_VAR_cache_ttl_user_data="600"
export TF_VAR_cache_ttl_todo_data="180"
```

#### **Windows (PowerShell):**
```powershell
# Docker Host (detectado automáticamente por el script)
$env:TF_VAR_docker_host="npipe:////./pipe/docker_engine"  # Docker Desktop Windows

# Network Subnet (cambiar si hay conflicto)
$env:TF_VAR_docker_network_subnet="192.168.100.0/24"

# Redis Password (cambiar por seguridad)
$env:TF_VAR_redis_password="mi-password-segura"

# Redis Port (cambiar si está ocupado)
$env:TF_VAR_redis_port="6379"

# Redis Version (opcional)
$env:TF_VAR_redis_version="7.0-alpine"

# Redis Memory Configuration (opcional)
$env:TF_VAR_redis_memory_limit="256mb"
$env:TF_VAR_redis_memory_policy="allkeys-lru"

# Cache TTL Configuration (opcional)
$env:TF_VAR_cache_ttl_default="300"
$env:TF_VAR_cache_ttl_user_data="600"
$env:TF_VAR_cache_ttl_todo_data="180"
```

### **✅ Ventajas del sistema:**
- **No tocar código fuente** - Mantener código limpio
- **Configuración por entorno** - Cada desarrollador su configuración
- **Seguridad** - Passwords no en el código
- **Flexibilidad** - Cambios sin commits
- **Detección automática** - Funciona en cualquier máquina
- **Verificación automática** - Confirma que todo está bien

---

## 📝 COMANDOS PASO A PASO

### **🚀 MÉTODO RECOMENDADO:**

### **PASO 1: Navegar al directorio**

#### **macOS/Linux:**
```bash
cd infrastructure/environments/dev
```

#### **Windows (PowerShell):**
```powershell
Set-Location infrastructure\environments\dev
# o
cd infrastructure\environments\dev
```

### **PASO 2: Configurar entorno automáticamente**

#### **macOS/Linux:**
```bash
# IMPORTANTE: Debes estar en el directorio correcto
pwd
# Debe mostrar: /ruta/al/proyecto/infrastructure/environments/dev

# Ejecutar script automático (detecta todo y configura)
./setup-env.sh
```

#### **Windows (PowerShell):**
```powershell
# IMPORTANTE: Debes estar en el directorio correcto
Get-Location
# Debe mostrar: C:\ruta\al\proyecto\infrastructure\environments\dev

# Ejecutar script automático (detecta todo y configura)
.\setup-env.sh
```

# SALIDA ESPERADA:
# 🚀 Configurando entorno para Terraform...
# 🔍 Detectando configuración de Docker...
# ✅ Colima detectado: /Users/USERNAME/.colima/docker.sock
# 🔍 Verificando conflictos de red...
# ✅ No hay conflictos de red detectados
# 📝 Creando archivo .env.local...
# ✅ Archivo .env.local creado exitosamente en: /ruta/al/proyecto/infrastructure/environments/dev/.env.local
# 🔄 Cargando variables de entorno...
# ✅ Variables cargadas exitosamente
# 🧪 Verificando conexión con Docker...
# ✅ Docker funciona correctamente
# 🌐 Verificando red Docker...
# ✅ Red Docker creada: microservices-dev-network
# 🎉 ¡Configuración completada exitosamente!
```

### **PASO 3: Inicializar Terraform**
```bash
# macOS/Linux/Windows (PowerShell)
terraform init

# SALIDA ESPERADA:
# Initializing the backend...
# Initializing modules...
# - redis in ../../modules/redis
# Initializing provider plugins...
# - Finding kreuzwerker/docker versions matching "~> 3.0"...
# - Installing kreuzwerker/docker v3.6.2...
# Terraform has been successfully initialized!
```

### **PASO 4: Revisar el plan**
```bash
# macOS/Linux/Windows (PowerShell)
terraform plan

# SALIDA ESPERADA:
# Plan: 3 to add, 0 to change, 0 to destroy.
# + data.docker_network.microservices_network will be read
# + module.redis.docker_container.redis[0] will be created
# + module.redis.docker_image.redis[0] will be created
# + module.redis.docker_volume.redis_data[0] will be created
```

### **PASO 5: Aplicar la infraestructura**
```bash
# macOS/Linux/Windows (PowerShell)
terraform apply -auto-approve

# SALIDA ESPERADA:
# Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
# Outputs:
# deployment_phase = "local"
# environment = "dev"
# network_name = "microservices-dev-network"
# project_name = "microservices"
# redis_endpoint = "localhost:6379"
```

### **PASO 6: Verificar que funciona**

#### **macOS/Linux:**
```bash
# Ver contenedores
docker ps | grep redis

# Probar Redis
docker exec microservices-redis-dev redis-cli -a redis123 ping
```

#### **Windows (PowerShell):**
```powershell
# Ver contenedores
docker ps | Select-String redis

# Probar Redis
docker exec microservices-redis-dev redis-cli -a redis123 ping
```

#### **SALIDA ESPERADA (ambas plataformas):**
```
# ffcd08b8b66e   755105238729   "docker-entrypoint.s…"   7 seconds ago   Up 7 seconds (health: starting)   0.0.0.0:6379->6379/tcp   microservices-redis-dev

# PONG
# Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
```

---

## 🔍 CÓMO FUNCIONA EL SISTEMA (MUY DETALLADO)

### **📋 Flujo completo paso a paso:**

```
1. Usuario ejecuta: ./setup-env.sh
   ↓
2. Script detecta Docker (Colima o Docker Desktop)
   ↓
3. Script crea archivo .env.local con variables
   ↓
4. Script carga variables: source .env.local
   ↓
5. Terraform lee variables: TF_VAR_* → var.*
   ↓
6. Terraform pasa variables al módulo Redis
   ↓
7. Módulo Redis crea contenedor Docker
   ↓
8. Redis funciona con configuración personalizada
```

### **🔧 Variables de entorno → Terraform:**

```bash
# Variables de entorno (en .env.local)
export TF_VAR_docker_host="unix:///Users/USERNAME/.colima/docker.sock"
export TF_VAR_redis_password="mi-password-segura"

# Terraform las lee automáticamente
var.docker_host = "unix:///Users/USERNAME/.colima/docker.sock"
var.redis_password = "mi-password-segura"

# Se pasan al módulo Redis
module "redis" {
  redis_password = var.redis_password  # ← Aquí se pasa
  docker_host = var.docker_host        # ← Aquí se pasa
}
```

### **📁 Archivos que se crean automáticamente:**

```
infrastructure/environments/dev/
├── .env.local              # ← Creado por setup-env.sh (NO subir al repo)
├── .gitignore              # ← Protege archivos sensibles
├── env.template            # ← Template para copiar
├── setup-env.sh            # ← Script automático
└── TERRAFORM-GUIDE.md      # ← Esta guía
```

### **📍 UBICACIÓN EXACTA DEL .env.local:**

**El archivo `.env.local` se crea EXACTAMENTE en:**
```bash
# Ruta completa del archivo
infrastructure/environments/dev/.env.local

# Verificar ubicación
ls -la infrastructure/environments/dev/.env.local
# Debe mostrar: -rw-r--r-- 1 user user 1234 fecha .env.local
```

**⚠️ IMPORTANTE:**
- **NO crear** `.env.local` en el directorio raíz del proyecto
- **NO crear** `.env.local` en `infrastructure/`
- **SÍ crear** `.env.local` en `infrastructure/environments/dev/`
- **Terraform busca** las variables en el directorio donde se ejecuta

### **✅ Verificación de que funciona:**

```bash
# Verificar variables cargadas
echo "Docker Host: $TF_VAR_docker_host"
echo "Redis Password: $TF_VAR_redis_password"

# Verificar que Terraform las lee
echo 'var.redis_password' | terraform console

# Verificar que se pasan al módulo
echo 'module.redis.redis_password' | terraform console
```

### **🔄 Si quieres cambiar configuración:**

```bash
# Opción 1: Editar .env.local
nano .env.local
source .env.local
terraform apply -auto-approve

# Opción 2: Ejecutar script nuevamente
./setup-env.sh
terraform apply -auto-approve

# Opción 3: Cambiar variable específica
export TF_VAR_redis_password="nueva-password"
terraform apply -auto-approve
```

---

## 🚨 TROUBLESHOOTING

### **Error: `command not found: terraform`**

#### **macOS:**
```bash
# Solución: Instalar Terraform
brew install terraform
```

#### **Windows:**
```powershell
# Solución: Instalar Terraform
choco install terraform
# o
scoop install terraform
```

### **Error: `Error pinging Docker server`**

#### **macOS:**
```bash
# Solución: Verificar Docker y configurar DOCKER_HOST
docker ps  # Debe funcionar
export DOCKER_HOST="unix:///Users/TU-USUARIO/.colima/docker.sock"  # Colima
# o
export DOCKER_HOST="unix:///var/run/docker.sock"                   # Docker Desktop
```

#### **Windows:**
```powershell
# Solución: Verificar Docker Desktop
docker ps  # Debe funcionar
$env:DOCKER_HOST="npipe:////./pipe/docker_engine"  # Docker Desktop Windows
```

### **Error: `Pool overlaps with other one`**

#### **macOS/Linux:**
```bash
# Solución: Crear red manualmente
docker network create --driver bridge --subnet=192.168.100.0/24 microservices-dev-network
```

#### **Windows:**
```powershell
# Solución: Crear red manualmente
docker network create --driver bridge --subnet=192.168.100.0/24 microservices-dev-network
```

### **Error: `No valid credential sources found` (AWS)**
```bash
# Solución: Esto es normal en fase local, ignorar
# Solo aparece si intentas usar recursos de AWS
```

### **Error: `Invalid provider configuration`**

#### **macOS/Linux:**
```bash
# Solución: Re-inicializar Terraform
rm -rf .terraform .terraform.lock.hcl
terraform init
```

#### **Windows:**
```powershell
# Solución: Re-inicializar Terraform
Remove-Item -Recurse -Force .terraform
Remove-Item .terraform.lock.hcl
terraform init
```

### **Redis no responde:**
```bash
# Verificar logs (ambas plataformas)
docker logs microservices-redis-dev

# Reiniciar contenedor (ambas plataformas)
docker restart microservices-redis-dev
```

### **Error: `No such file or directory: .env.local`**

#### **macOS/Linux:**
```bash
# Causa: El archivo .env.local no existe o no está en el directorio correcto
# Solución:
pwd  # Debe mostrar: infrastructure/environments/dev
./setup-env.sh  # Crear archivo automáticamente
ls -la .env.local  # Verificar que se creó
```

#### **Windows:**
```powershell
# Causa: El archivo .env.local no existe o no está en el directorio correcto
# Solución:
Get-Location  # Debe mostrar: infrastructure\environments\dev
.\setup-env.sh  # Crear archivo automáticamente
Get-ChildItem .env.local  # Verificar que se creó
```

### **Error: `Reference to undeclared input variable`**
```bash
# Causa: Variable no declarada en variables.tf
# Solución: Verificar que todas las variables estén en variables.tf
grep -r "var\." main.tf  # Ver qué variables se usan
grep -r "variable" variables.tf  # Ver qué variables están declaradas
```

---

## 📚 CONCEPTOS APRENDIDOS

### **1. Infrastructure as Code (IaC)**
- **Definición**: Definir infraestructura como código versionable
- **Beneficios**: Consistencia, automatización, colaboración
- **Herramienta**: Terraform

### **2. Patrón Cache Aside**
- **Definición**: La aplicación maneja la caché directamente
- **Flujo**: App → Cache → DB → Cache → App
- **Implementación**: Redis con TTL configurable

### **3. Arquitectura Híbrida**
- **Fase 1 (Local)**: Docker para desarrollo
- **Fase 2 (Cloud)**: AWS para producción
- **Beneficio**: Costo cero en desarrollo, escalabilidad en producción

### **4. Módulos de Terraform**
- **Definición**: Código reutilizable y versionable
- **Estructura**: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- **Beneficio**: Reutilización entre entornos

### **5. Variables y Outputs**
- **Variables**: Parámetros de entrada configurables
- **Outputs**: Valores de salida para otros módulos
- **Tipos**: `string`, `number`, `list`, `map`, `bool`

### **6. Data Sources**
- **Definición**: Referenciar recursos existentes
- **Uso**: `data "docker_network" "existing_network"`
- **Beneficio**: No duplicar recursos

---

## 🎯 PRÓXIMOS PASOS

### **Tarea 3: Configurar Jenkins**
- [ ] Crear módulo Jenkins
- [ ] Configurar CI/CD pipelines
- [ ] Integrar con Terraform

### **Tarea 4: Implementar más patrones**
- [ ] Circuit Breaker pattern
- [ ] Service Discovery
- [ ] Load Balancing

### **Tarea 5: Testing y Monitoreo**
- [ ] Tests automatizados
- [ ] Health checks
- [ ] Logging centralizado

---

## 📞 COMANDOS DE EMERGENCIA

### **Limpiar todo y empezar de nuevo:**

#### **macOS/Linux:**
```bash
# Destruir infraestructura
terraform destroy -auto-approve

# Limpiar Docker
docker stop microservices-redis-dev
docker rm microservices-redis-dev
docker volume rm microservices-redis-dev-data
docker network rm microservices-dev-network

# Limpiar Terraform
rm -rf .terraform .terraform.lock.hcl terraform.tfstate*
```

#### **Windows:**
```powershell
# Destruir infraestructura
terraform destroy -auto-approve

# Limpiar Docker
docker stop microservices-redis-dev
docker rm microservices-redis-dev
docker volume rm microservices-redis-dev-data
docker network rm microservices-dev-network

# Limpiar Terraform
Remove-Item -Recurse -Force .terraform
Remove-Item .terraform.lock.hcl
Remove-Item terraform.tfstate*
```

### **Verificar estado:**
```bash
# Estado de Terraform (ambas plataformas)
terraform show

# Estado de Docker (ambas plataformas)
docker ps -a
docker network ls
docker volume ls
```

---

## 📖 RECURSOS ADICIONALES

- [Terraform Documentation](https://www.terraform.io/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Redis Documentation](https://redis.io/documentation)
- [Cache Aside Pattern](https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/Strategies.html)

---

## 👥 PARA DESARROLLADORES

### **🎯 INSTRUCCIONES PARA NUEVOS DESARROLLADORES:**

#### **📋 Lo que necesitas hacer (SÚPER FÁCIL):**

#### **macOS/Linux:**
```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd practice-microservice-app-example

# 2. Ir al directorio de infraestructura (IMPORTANTE: debe ser este directorio exacto)
cd infrastructure/environments/dev

# 3. Verificar que estás en el lugar correcto
pwd
# Debe mostrar: /ruta/al/proyecto/infrastructure/environments/dev

# 4. Ejecutar script automático (detecta TODO)
./setup-env.sh

# 5. Aplicar infraestructura
terraform apply -auto-approve

# ¡LISTO! Redis está funcionando
```

#### **Windows (PowerShell):**
```powershell
# 1. Clonar el repositorio
git clone <repo-url>
Set-Location practice-microservice-app-example

# 2. Ir al directorio de infraestructura (IMPORTANTE: debe ser este directorio exacto)
Set-Location infrastructure\environments\dev

# 3. Verificar que estás en el lugar correcto
Get-Location
# Debe mostrar: C:\ruta\al\proyecto\infrastructure\environments\dev

# 4. Ejecutar script automático (detecta TODO)
.\setup-env.sh

# 5. Aplicar infraestructura
terraform apply -auto-approve

# ¡LISTO! Redis está funcionando
```

#### **📍 IMPORTANTE: Ubicación del .env.local**

#### **macOS/Linux:**
```bash
# El archivo .env.local se crea en:
infrastructure/environments/dev/.env.local

# Verificar que se creó correctamente
ls -la .env.local
# Debe mostrar: -rw-r--r-- 1 user user 1234 fecha .env.local
```

#### **Windows:**
```powershell
# El archivo .env.local se crea en:
infrastructure\environments\dev\.env.local

# Verificar que se creó correctamente
Get-ChildItem .env.local
# Debe mostrar: Mode, LastWriteTime, Length, Name
```

#### **✅ Lo que el script hace automáticamente:**
- **Detecta tu Docker** (Colima o Docker Desktop)
- **Configura variables** de entorno
- **Crea red Docker** si no existe
- **Verifica conexión** con Docker
- **Muestra resumen** de configuración

#### **❌ Lo que NO necesitas hacer:**
- ❌ Editar archivos de código
- ❌ Cambiar IPs (a menos que haya conflicto)
- ❌ Configurar Docker manualmente
- ❌ Modificar variables en el código

### **🔧 INSTRUCCIONES PARA DEVOPS SENIORS:**

#### **📋 Antes de aplicar cambios:**
```bash
# 1. Revisar configuración
cat .env.local

# 2. Verificar plan
terraform plan

# 3. Aplicar cambios
terraform apply -auto-approve
```

#### **📋 Si hay conflictos de red:**
#### **macOS/Linux:**
```bash
# 1. Verificar redes existentes
docker network ls

# 2. Cambiar subnet en .env.local
export TF_VAR_docker_network_subnet="192.168.200.0/24"

# 3. Recrear red
docker network rm microservices-dev-network
docker network create --driver bridge --subnet=192.168.200.0/24 microservices-dev-network

# 4. Aplicar cambios
terraform apply -auto-approve
```

#### **Windows:**
```powershell
# 1. Verificar redes existentes
docker network ls

# 2. Cambiar subnet en .env.local
$env:TF_VAR_docker_network_subnet="192.168.200.0/24"

# 3. Recrear red
docker network rm microservices-dev-network
docker network create --driver bridge --subnet=192.168.200.0/24 microservices-dev-network

# 4. Aplicar cambios
terraform apply -auto-approve
```

#### **📋 Mantenimiento:**
- **Documentar cambios** en la configuración
- **Mantener esta guía actualizada**
- **Verificar que el script funciona** en diferentes sistemas operativos
- **Revisar conflictos** de red periódicamente

### **🚨 SITUACIONES ESPECIALES:**

#### **Si tienes Docker Desktop y otro desarrollador tiene Colima:**
```bash
# El script detecta automáticamente
# No necesitas cambiar nada
./setup-env.sh
```

#### **Si hay conflictos de IP:**
```bash
# Cambiar subnet en .env.local
export TF_VAR_docker_network_subnet="192.168.200.0/24"

# Recrear red
docker network rm microservices-dev-network
docker network create --driver bridge --subnet=192.168.200.0/24 microservices-dev-network
```

#### **Si quieres cambiar password de Redis:**

#### **macOS/Linux:**
```bash
# Editar .env.local
nano .env.local

# Cambiar línea:
export TF_VAR_redis_password="mi-nueva-password"

# Recargar y aplicar
source .env.local
terraform apply -auto-approve
```

#### **Windows:**
```powershell
# Editar .env.local
notepad .env.local

# Cambiar línea:
$env:TF_VAR_redis_password="mi-nueva-password"

# Recargar y aplicar
terraform apply -auto-approve
```

### **📞 SOPORTE:**

#### **Si algo no funciona:**

#### **macOS/Linux:**
1. **Ejecutar script nuevamente**: `./setup-env.sh`
2. **Verificar Docker**: `docker ps`
3. **Verificar variables**: `echo $TF_VAR_docker_host`
4. **Preguntar al equipo o revisar la documentación** si persiste el problema

#### **Windows:**
1. **Ejecutar script nuevamente**: `.\setup-env.sh`
2. **Verificar Docker**: `docker ps`
3. **Verificar variables**: `echo $env:TF_VAR_docker_host`
4. **Preguntar al equipo o revisar la documentación** si persiste el problema

#### **Comandos de emergencia:**

#### **macOS/Linux:**
```bash
# Limpiar todo y empezar de nuevo
terraform destroy -auto-approve
docker network rm microservices-dev-network
./setup-env.sh
terraform apply -auto-approve
```

#### **Windows:**
```powershell
# Limpiar todo y empezar de nuevo
terraform destroy -auto-approve
docker network rm microservices-dev-network
.\setup-env.sh
terraform apply -auto-approve
```
