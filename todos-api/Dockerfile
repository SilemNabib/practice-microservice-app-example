FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app
USER nodejs

ENV TODO_API_PORT=8082
ENV JWT_SECRET=PRFT
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV REDIS_PASSWORD=redis123
ENV REDIS_CHANNEL=log_channel
ENV ZIPKIN_URL=http://zipkin:9411/api/v2/spans
# Cache Aside Pattern TTL Configuration
ENV CACHE_TTL_DEFAULT=300
ENV CACHE_TTL_TODO_DATA=180
ENV CACHE_TTL_USER_DATA=600

EXPOSE 8082

CMD ["npm", "start"]
