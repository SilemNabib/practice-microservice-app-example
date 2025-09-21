#!/bin/bash
# ===========================================
# DOCKER SOCKET PERMISSIONS FIX
# ===========================================

echo "🔧 Configurando permisos del socket Docker..."

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
    echo "✅ Docker funciona correctamente"
else
    echo "❌ Error: Docker no funciona"
    exit 1
fi

echo "🎉 Configuración de Docker completada"
