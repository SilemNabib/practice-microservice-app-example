#!/bin/bash
# ===========================================
# SIMPLE DOCKER SOCKET CONFIGURATION
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

echo "✅ Socket Docker configurado correctamente"
echo "🚀 Iniciando Jenkins..."
