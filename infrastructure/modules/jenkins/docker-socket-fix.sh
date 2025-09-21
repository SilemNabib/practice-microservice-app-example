#!/bin/bash
# ===========================================
# DOCKER CLI INSTALLATION AND SOCKET FIX
# ===========================================

echo "🔧 Instalando Docker CLI y configurando permisos..."

# Actualizar paquetes
echo "📦 Actualizando paquetes..."
apt-get update -qq

# Instalar Docker CLI
echo "🐳 Instalando Docker CLI..."
apt-get install -y -qq docker.io

# Instalar Docker Compose v2
echo "🔧 Instalando Docker Compose v2..."
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Esperar a que el socket esté disponible
while [ ! -S /var/run/docker.sock ]; do
    echo "⏳ Esperando socket Docker..."
    sleep 2
done

# Configurar permisos del socket para que sea accesible por todos
echo "🔑 Configurando permisos del socket..."
chmod 666 /var/run/docker.sock

# Verificar que Docker funciona
echo "🧪 Verificando conexión Docker..."
if docker ps > /dev/null 2>&1; then
    echo "✅ Docker CLI funciona correctamente"
else
    echo "❌ Error: Docker CLI no funciona"
    exit 1
fi

# Verificar Docker Compose
echo "🧪 Verificando Docker Compose..."
if docker-compose --version > /dev/null 2>&1; then
    echo "✅ Docker Compose funciona correctamente"
else
    echo "❌ Error: Docker Compose no funciona"
    exit 1
fi

echo "🎉 Instalación de Docker CLI completada"
