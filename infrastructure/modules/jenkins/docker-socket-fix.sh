#!/bin/bash
# ===========================================
# DOCKER SOCKET CONFIGURATION WITH PERMISSIONS FIX
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

# Intentar cambiar ownership si es posible (falla silenciosamente)
echo "🔧 Intentando ajustar ownership del socket..."
chown root:root /var/run/docker.sock 2>/dev/null || echo "⚠️  No se pudo cambiar ownership (normal en contenedores)"

# Verificar que Docker funciona
echo "🧪 Verificando conexión Docker..."
if docker ps > /dev/null 2>&1; then
    echo "✅ Docker funciona correctamente"
else
    echo "❌ Docker no funciona - continuando con Jenkins..."
    echo "⚠️  Docker-in-Docker puede requerir configuración adicional"
fi

echo "✅ Socket Docker configurado"
echo "🚀 Iniciando Jenkins..."
