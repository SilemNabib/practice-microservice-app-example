'use strict';

const CircuitBreaker = require('opossum');

/**
 * Circuit Breaker configuration for database operations
 */
const circuitBreakerOptions = {
    timeout: 5000, // 5 seconds timeout
    errorThresholdPercentage: 50, // Open circuit if 50% of requests fail
    resetTimeout: 30000, // Try again after 30 seconds
    rollingCountTimeout: 10000, // 10 second rolling window
    rollingCountBuckets: 10, // Number of buckets in the rolling window
    name: 'MongoDB Circuit Breaker',
    group: 'database-operations'
};

/**
 * Creates a circuit breaker wrapper for database operations
 * @param {Object} collection - MongoDB collection instance
 * @returns {Object} - Object with circuit breaker wrapped methods
 */
function createDatabaseCircuitBreaker(collection) {
    // Circuit breaker for find operations
    const findCircuitBreaker = new CircuitBreaker(async (query, options = {}) => {
        console.log('[CIRCUIT-BREAKER] Executing find operation');
        return await collection.find(query, options).toArray();
    }, circuitBreakerOptions);

    // Circuit breaker for findOne operations
    const findOneCircuitBreaker = new CircuitBreaker(async (query, options = {}) => {
        console.log('[CIRCUIT-BREAKER] Executing findOne operation');
        return await collection.findOne(query, options);
    }, circuitBreakerOptions);

    // Circuit breaker for insertOne operations
    const insertOneCircuitBreaker = new CircuitBreaker(async (document) => {
        console.log('[CIRCUIT-BREAKER] Executing insertOne operation');
        return await collection.insertOne(document);
    }, circuitBreakerOptions);

    // Circuit breaker for deleteOne operations
    const deleteOneCircuitBreaker = new CircuitBreaker(async (query) => {
        console.log('[CIRCUIT-BREAKER] Executing deleteOne operation');
        return await collection.deleteOne(query);
    }, circuitBreakerOptions);

    // Circuit breaker for updateOne operations
    const updateOneCircuitBreaker = new CircuitBreaker(async (query, update, options = {}) => {
        console.log('[CIRCUIT-BREAKER] Executing updateOne operation');
        return await collection.updateOne(query, update, options);
    }, circuitBreakerOptions);

    // Event listeners for monitoring
    const setupEventListeners = (breaker, operationName) => {
        breaker.on('open', () => {
            console.warn(`[CIRCUIT-BREAKER] ${operationName} circuit breaker opened - requests will be rejected`);
        });

        breaker.on('halfOpen', () => {
            console.info(`[CIRCUIT-BREAKER] ${operationName} circuit breaker half-open - testing if service recovered`);
        });

        breaker.on('close', () => {
            console.info(`[CIRCUIT-BREAKER] ${operationName} circuit breaker closed - service is healthy`);
        });

        breaker.on('reject', () => {
            console.warn(`[CIRCUIT-BREAKER] ${operationName} request rejected - circuit breaker is open`);
        });

        breaker.on('timeout', () => {
            console.error(`[CIRCUIT-BREAKER] ${operationName} request timed out`);
        });

        breaker.on('failure', (error) => {
            console.error(`[CIRCUIT-BREAKER] ${operationName} request failed:`, error.message);
        });

        breaker.on('success', () => {
            console.log(`[CIRCUIT-BREAKER] ${operationName} request succeeded`);
        });
    };

    // Setup event listeners for all circuit breakers
    setupEventListeners(findCircuitBreaker, 'Find');
    setupEventListeners(findOneCircuitBreaker, 'FindOne');
    setupEventListeners(insertOneCircuitBreaker, 'InsertOne');
    setupEventListeners(deleteOneCircuitBreaker, 'DeleteOne');
    setupEventListeners(updateOneCircuitBreaker, 'UpdateOne');

    return {
        find: findCircuitBreaker,
        findOne: findOneCircuitBreaker,
        insertOne: insertOneCircuitBreaker,
        deleteOne: deleteOneCircuitBreaker,
        updateOne: updateOneCircuitBreaker,
        
        // Utility methods
        getStats: () => ({
            find: findCircuitBreaker.stats,
            findOne: findOneCircuitBreaker.stats,
            insertOne: insertOneCircuitBreaker.stats,
            deleteOne: deleteOneCircuitBreaker.stats,
            updateOne: updateOneCircuitBreaker.stats
        }),
        
        // Health check method
        isHealthy: () => {
            return findCircuitBreaker.closed && 
                   findOneCircuitBreaker.closed && 
                   insertOneCircuitBreaker.closed && 
                   deleteOneCircuitBreaker.closed && 
                   updateOneCircuitBreaker.closed;
        }
    };
}

module.exports = {
    createDatabaseCircuitBreaker,
    circuitBreakerOptions
};