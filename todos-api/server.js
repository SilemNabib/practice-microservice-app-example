'use strict';
const express = require('express')
const bodyParser = require("body-parser")
const jwt = require('express-jwt')

const ZIPKIN_URL = process.env.ZIPKIN_URL || 'http://127.0.0.1:9411/api/v2/spans';
const {Tracer, 
  BatchRecorder,
  jsonEncoder: {JSON_V2}} = require('zipkin');
  const CLSContext = require('zipkin-context-cls');  
const {HttpLogger} = require('zipkin-transport-http');
const zipkinMiddleware = require('zipkin-instrumentation-express').expressMiddleware;

const logChannel = process.env.REDIS_CHANNEL || 'log_channel';
// Redis v4 client configuration
const { createClient } = require('redis');

// Redis v4 configuration - using URL format for better compatibility
const redisUrl = `redis://:${process.env.REDIS_PASSWORD || 'redis123'}@${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}`;
console.log('🔗 Connecting to Redis:', redisUrl.replace(/:\/\/:[^@]+@/, '://***@')); // Hide password in logs

const redisClient = createClient({
  url: redisUrl,
  socket: {
    reconnectStrategy: function (retries) {
      if (retries > 10) {
        console.log('❌ Max Redis reconnection attempts reached');
        return new Error('Max Redis reconnection attempts reached');
      }
      console.log(`🔄 Redis reconnection attempt #${retries}`);
      return Math.min(retries * 100, 2000);
    }
  }
});

// Add Redis connection event handlers
redisClient.on('connect', () => {
    console.log('✅ Redis client connected');
});

redisClient.on('error', (err) => {
    console.error('❌ Redis client error:', err);
});

redisClient.on('ready', () => {
    console.log('🚀 Redis client ready');
});

redisClient.on('reconnecting', () => {
    console.log('🔄 Redis client reconnecting...');
});

// Connect to Redis
redisClient.connect().catch(console.error);
const port = process.env.TODO_API_PORT || 8082
const jwtSecret = process.env.JWT_SECRET || "foo"

const app = express()

// tracing
const ctxImpl = new CLSContext('zipkin');
const recorder = new  BatchRecorder({
  logger: new HttpLogger({
    endpoint: ZIPKIN_URL,
    jsonEncoder: JSON_V2
  })
});
const localServiceName = 'todos-api';
const tracer = new Tracer({ctxImpl, recorder, localServiceName});


app.use(jwt({ secret: jwtSecret }))
app.use(zipkinMiddleware({tracer}));
app.use(function (err, req, res, next) {
  if (err.name === 'UnauthorizedError') {
    res.status(401).send({ message: 'invalid token' })
  }
})
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

const routes = require('./routes')
routes(app, {tracer, redisClient, logChannel})

app.listen(port, function () {
  console.log('todo list RESTful API server started on: ' + port)
})
