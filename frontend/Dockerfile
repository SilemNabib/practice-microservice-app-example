# Multi-stage build for Vue.js frontend
# Stage 1: Build the application
FROM node:8.17.0-alpine as build-stage

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the application for production
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine as production-stage

# Install envsubst for environment variable substitution
RUN apk add --no-cache gettext

# Copy built assets from build stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy nginx template
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template

# Copy startup script
COPY script-entrypoint.sh /script-entrypoint.sh
RUN chmod +x /script-entrypoint.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx with environment variable substitution
ENTRYPOINT ["/script-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]