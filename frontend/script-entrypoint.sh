#!/bin/sh

# Set default values if not provided
export AUTH_API_URL=${AUTH_API_URL:-"http://auth-api:8000"}
export TODOS_API_URL=${TODOS_API_URL:-"http://todos-api:8082"}
export ZIPKIN_URL=${ZIPKIN_URL:-"http://zipkin:9411/api/v2/spans"}

# Substitute environment variables in nginx config
envsubst '${AUTH_API_URL} ${TODOS_API_URL} ${ZIPKIN_URL}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start nginx
exec "$@"