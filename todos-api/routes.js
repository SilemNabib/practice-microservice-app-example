'use strict';
const TodoController = require('./todoController');
module.exports = function (app, {tracer, redisClient, logChannel, db}) {
  const todoController = new TodoController({tracer, redisClient, logChannel, db});
  
  // Health check endpoint that includes circuit breaker status (no JWT required)
  app.route('/health')
    .get(function(req, res) {
      const circuitBreakerStats = todoController._dbCircuitBreaker.getStats();
      const isHealthy = todoController._dbCircuitBreaker.isHealthy();
      
      res.json({
        status: isHealthy ? 'healthy' : 'degraded',
        timestamp: new Date().toISOString(),
        circuitBreaker: {
          healthy: isHealthy,
          stats: circuitBreakerStats
        }
      });
    });

  app.route('/todos')
    .get(function(req,resp) {return todoController.list(req,resp)})
    .post(function(req,resp) {return todoController.create(req,resp)});

  app.route('/todos/:taskId')
    .delete(function(req,resp) {return todoController.delete(req,resp)});
};