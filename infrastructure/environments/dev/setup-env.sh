#!/bin/bash

# ===========================================
# SCRIPT AUTOMÁTICO DE CONFIGURACIÓN DE ENTORNO
# ===========================================
# 
# Este script:
# 1. Detecta tu configuración de Docker
# 2. Crea archivo .env.local personalizado
# 3. Verifica que todo esté configurado correctamente

set -e  # Salir si hay algún error

echo "🚀 Configurando entorno para Terraform..."

# ===========================================
# DETECTAR CONFIGURACIÓN DE DOCKER
# ===========================================

echo "🔍 Detectando configuración de Docker..."

DOCKER_HOST=""
NETWORK_SUBNET="192.168.100.0/24"

# Verificar si Colima está corriendo
if command -v colima &> /dev/null; then
    if colima status &> /dev/null; then
        USERNAME=$(whoami)
        COLIMA_SOCKET="/Users/$USERNAME/.colima/docker.sock"
        if [ -S "$COLIMA_SOCKET" ]; then
            DOCKER_HOST="unix://$COLIMA_SOCKET"
            echo "✅ Colima detectado: $DOCKER_HOST"
        fi
    fi
fi

# Si no se detectó Colima, verificar Docker Desktop
if [ -z "$DOCKER_HOST" ]; then
    DOCKER_DESKTOP_SOCKET="/var/run/docker.sock"
    if [ -S "$DOCKER_DESKTOP_SOCKET" ]; then
        DOCKER_HOST="unix://$DOCKER_DESKTOP_SOCKET"
        echo "✅ Docker Desktop detectado: $DOCKER_HOST"
    fi
fi

# Si no se detectó nada
if [ -z "$DOCKER_HOST" ]; then
    echo "❌ No se pudo detectar Docker. Por favor:"
    echo "   - Asegúrate de que Docker Desktop o Colima esté corriendo"
    echo "   - O configura manualmente TF_VAR_docker_host"
    exit 1
fi

# ===========================================
# VERIFICAR CONFLICTOS DE RED
# ===========================================

echo "🔍 Verificando conflictos de red..."

# Verificar si la red ya existe
if docker network ls | grep -q "microservices-dev-network"; then
    echo "⚠️  La red 'microservices-dev-network' ya existe"
    echo "   Puedes continuar o cambiar el subnet si hay conflictos"
else
    echo "✅ No hay conflictos de red detectados"
fi

# ===========================================
# CREAR ARCHIVO .env.local
# ===========================================

echo "📝 Creando archivo .env.local..."

cat > .env.local << EOF
# ===========================================
# CONFIGURACIÓN AUTOMÁTICA - $(date)
# ===========================================
# Generado automáticamente por setup-env.sh
# NO EDITAR MANUALMENTE - Usar este script para cambios

# Docker Host (detectado automáticamente)
export TF_VAR_docker_host="$DOCKER_HOST"

# Docker Network Subnet
export TF_VAR_docker_network_subnet="$NETWORK_SUBNET"

# Redis Configuration
export TF_VAR_redis_password="redis123"
export TF_VAR_redis_port="6379"
export TF_VAR_redis_version="7.0-alpine"
export TF_VAR_redis_memory_limit="256mb"
export TF_VAR_redis_memory_policy="allkeys-lru"

# Cache TTL Configuration
export TF_VAR_cache_ttl_default="300"
export TF_VAR_cache_ttl_user_data="600"
export TF_VAR_cache_ttl_todo_data="180"

# Environment Configuration
export TF_VAR_deployment_phase="local"
export TF_VAR_project_name="microservices"
export TF_VAR_environment="dev"

# Terraform Configuration
export TF_LOG="INFO"
export TF_LOG_PATH="./terraform.log"

# ===========================================
# VERIFICACIÓN
# ===========================================
echo "✅ Variables de entorno configuradas:"
echo "   Docker Host: \$TF_VAR_docker_host"
echo "   Network Subnet: \$TF_VAR_docker_network_subnet"
echo "   Redis Port: \$TF_VAR_redis_port"
EOF

echo "✅ Archivo .env.local creado exitosamente"

# ===========================================
# CARGAR VARIABLES Y VERIFICAR
# ===========================================

echo "🔄 Cargando variables de entorno..."
source .env.local

echo "✅ Variables cargadas exitosamente"

# ===========================================
# VERIFICAR DOCKER
# ===========================================

echo "🧪 Verificando conexión con Docker..."
if docker ps &> /dev/null; then
    echo "✅ Docker funciona correctamente"
else
    echo "❌ Error conectando con Docker"
    echo "   Verifica que Docker esté corriendo"
    exit 1
fi

# ===========================================
# CREAR RED DOCKER SI NO EXISTE
# ===========================================

echo "🌐 Verificando red Docker..."
if ! docker network ls | grep -q "microservices-dev-network"; then
    echo "📡 Creando red Docker..."
    docker network create --driver bridge --subnet="$NETWORK_SUBNET" microservices-dev-network
    echo "✅ Red Docker creada: microservices-dev-network"
else
    echo "✅ Red Docker ya existe: microservices-dev-network"
fi

# ===========================================
# RESUMEN FINAL
# ===========================================

echo ""
echo "🎉 ¡Configuración completada exitosamente!"
echo ""
echo "📋 Resumen de configuración:"
echo "   Docker Host: $TF_VAR_docker_host"
echo "   Network Subnet: $TF_VAR_docker_network_subnet"
echo "   Redis Port: $TF_VAR_redis_port"
echo "   Redis Password: $TF_VAR_redis_password"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. terraform init"
echo "   2. terraform plan"
echo "   3. terraform apply -auto-approve"
echo ""
echo "💡 Para cambiar configuración:"
echo "   - Edita .env.local manualmente, o"
echo "   - Ejecuta este script nuevamente: ./setup-env.sh"
echo ""
