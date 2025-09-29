// Script para probar el patrón Cache-Aside
// Ejecutar con: node cache-test.js

const redis = require('redis');

// Configuración de Redis (debe coincidir con docker-compose.yaml)
const redisClient = redis.createClient({
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
    retry_strategy: function (options) {
        if (options.error && options.error.code === 'ECONNREFUSED') {
            return new Error('The server refused the connection');
        }
        if (options.total_retry_time > 1000 * 60 * 60) {
            return new Error('Retry time exhausted');
        }
        if (options.attempt > 10) {
            console.log('reattemtping to connect to redis, attempt #' + options.attempt)
            return undefined;
        }
        return Math.min(options.attempt * 100, 2000);
    }
});

async function testCacheOperations() {
    console.log('🔍 Testing Cache-Aside Pattern Operations...\n');
    
    // Test 1: Verificar conexión a Redis
    console.log('1. Testing Redis connection...');
    redisClient.ping((err, result) => {
        if (err) {
            console.error('❌ Redis connection failed:', err);
            return;
        }
        console.log('✅ Redis connection successful:', result);
    });
    
    // Test 2: Simular operaciones de cache
    const testKey = 'todos:user:testuser';
    const testData = [
        { id: 1, content: 'Test todo 1' },
        { id: 2, content: 'Test todo 2' }
    ];
    
    console.log('\n2. Testing cache SET operation...');
    redisClient.setex(testKey, 300, JSON.stringify(testData), (err) => {
        if (err) {
            console.error('❌ Cache SET failed:', err);
        } else {
            console.log('✅ Cache SET successful for key:', testKey);
            
            // Test 3: Verificar cache GET
            console.log('\n3. Testing cache GET operation...');
            redisClient.get(testKey, (err, result) => {
                if (err) {
                    console.error('❌ Cache GET failed:', err);
                } else if (result) {
                    console.log('✅ Cache GET successful. Data:', JSON.parse(result));
                } else {
                    console.log('❌ Cache GET returned null (cache miss)');
                }
                
                // Test 4: Verificar cache DELETE
                console.log('\n4. Testing cache DELETE operation...');
                redisClient.del(testKey, (err, result) => {
                    if (err) {
                        console.error('❌ Cache DELETE failed:', err);
                    } else {
                        console.log('✅ Cache DELETE successful. Keys deleted:', result);
                    }
                    
                    // Test 5: Verificar que el cache fue eliminado
                    console.log('\n5. Verifying cache was deleted...');
                    redisClient.get(testKey, (err, result) => {
                        if (err) {
                            console.error('❌ Cache verification failed:', err);
                        } else if (result === null) {
                            console.log('✅ Cache successfully deleted (null result)');
                        } else {
                            console.log('❌ Cache still exists:', result);
                        }
                        
                        console.log('\n🎉 Cache-Aside pattern test completed!');
                        console.log('\n📋 Para verificar el flujo en la aplicación:');
                        console.log('1. Ejecuta: docker-compose up');
                        console.log('2. Haz requests a la API de todos');
                        console.log('3. Observa los logs con prefijo [CACHE-ASIDE]');
                        
                        redisClient.quit();
                    });
                });
            });
        }
    });
}

// Ejecutar las pruebas
redisClient.on('connect', () => {
    console.log('🔗 Connected to Redis');
    testCacheOperations();
});

redisClient.on('error', (err) => {
    console.error('❌ Redis error:', err);
});