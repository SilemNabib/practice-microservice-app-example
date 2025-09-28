FROM node:8.17.0-alpine

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
ENV REDIS_CHANNEL=log_channel
ENV ZIPKIN_URL=http://zipkin:9411/api/v2/spans

EXPOSE 8082

CMD ["npm", "start"]