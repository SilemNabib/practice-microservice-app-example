#!/usr/bin/env node
/**
 * Test script for frontend
 * This script tests the frontend container and its integration with backend services
 */

const http = require('http');
const https = require('https');

// Configuration
const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost';
const AUTH_API_URL = process.env.AUTH_API_URL || 'http://localhost:8000';
const TODOS_API_URL = process.env.TODOS_API_URL || 'http://localhost:8082';
const USERS_API_URL = process.env.USERS_API_URL || 'http://localhost:8083';

// Helper function to make HTTP requests
function makeRequest(url, options = {}) {
    return new Promise((resolve, reject) => {
        const client = url.startsWith('https') ? https : http;
        
        const requestOptions = {
            method: options.method || 'GET',
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            timeout: 5000
        };
        
        const req = client.request(url, requestOptions, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const jsonBody = body ? JSON.parse(body) : {};
                    resolve({ statusCode: res.statusCode, headers: res.headers, body: jsonBody });
                } catch (e) {
                    resolve({ statusCode: res.statusCode, headers: res.headers, body: body });
                }
            });
        });
        
        req.on('error', reject);
        req.on('timeout', () => {
            req.destroy();
            reject(new Error('Request timeout'));
        });
        
        if (options.data) {
            req.write(JSON.stringify(options.data));
        }
        
        req.end();
    });
}

// Test frontend accessibility
async function testFrontendAccess() {
    console.log('🌐 Testing frontend accessibility...');
    
    try {
        const response = await makeRequest(FRONTEND_URL);
        console.log(`Status: ${response.statusCode}`);
        
        if (response.statusCode === 200) {
            console.log('✅ Frontend is accessible');
            return true;
        } else {
            console.log('❌ Frontend returned unexpected status');
            return false;
        }
    } catch (error) {
        console.error('❌ Error accessing frontend:', error.message);
        return false;
    }
}

// Test backend services
async function testBackendServices() {
    console.log('\n🔧 Testing backend services...');
    
    const services = [
        { name: 'Auth API', url: AUTH_API_URL },
        { name: 'Todos API', url: TODOS_API_URL },
        { name: 'Users API', url: USERS_API_URL }
    ];
    
    const results = [];
    
    for (const service of services) {
        try {
            const response = await makeRequest(service.url);
            const isHealthy = response.statusCode === 200 || response.statusCode === 401; // 401 is OK for auth without token
            console.log(`${service.name}: ${isHealthy ? '✅ OK' : '❌ FAIL'} (${response.statusCode})`);
            results.push(isHealthy);
        } catch (error) {
            console.log(`${service.name}: ❌ FAIL (${error.message})`);
            results.push(false);
        }
    }
    
    return results.every(result => result);
}

// Test authentication flow
async function testAuthFlow() {
    console.log('\n🔐 Testing authentication flow...');
    
    try {
        // Test login endpoint
        const loginResponse = await makeRequest(`${AUTH_API_URL}/login`, {
            method: 'POST',
            data: { username: 'admin', password: 'admin' }
        });
        
        if (loginResponse.statusCode === 200 && loginResponse.body.token) {
            console.log('✅ Authentication successful');
            
            // Test protected endpoint with token
            const token = loginResponse.body.token;
            const todosResponse = await makeRequest(`${TODOS_API_URL}/todos`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            
            if (todosResponse.statusCode === 200) {
                console.log('✅ Protected endpoint accessible with token');
                return true;
            } else {
                console.log('❌ Protected endpoint failed');
                return false;
            }
        } else {
            console.log('❌ Authentication failed');
            return false;
        }
    } catch (error) {
        console.error('❌ Error in auth flow:', error.message);
        return false;
    }
}

// Test static assets
async function testStaticAssets() {
    console.log('\n📦 Testing static assets...');
    
    const assets = [
        '/',
        '/static/js/app.js',
        '/static/css/app.css'
    ];
    
    const results = [];
    
    for (const asset of assets) {
        try {
            const response = await makeRequest(`${FRONTEND_URL}${asset}`);
            const isOk = response.statusCode === 200;
            console.log(`${asset}: ${isOk ? '✅ OK' : '❌ FAIL'} (${response.statusCode})`);
            results.push(isOk);
        } catch (error) {
            console.log(`${asset}: ❌ FAIL (${error.message})`);
            results.push(false);
        }
    }
    
    return results.every(result => result);
}

// Main test function
async function runTests() {
    console.log('🚀 Starting frontend tests...\n');
    
    try {
        const frontendAccess = await testFrontendAccess();
        const backendServices = await testBackendServices();
        const authFlow = await testAuthFlow();
        const staticAssets = await testStaticAssets();
        
        // Summary
        console.log('\n📊 Test Summary:');
        console.log(`Frontend Access: ${frontendAccess ? '✅ PASS' : '❌ FAIL'}`);
        console.log(`Backend Services: ${backendServices ? '✅ PASS' : '❌ FAIL'}`);
        console.log(`Authentication Flow: ${authFlow ? '✅ PASS' : '❌ FAIL'}`);
        console.log(`Static Assets: ${staticAssets ? '✅ PASS' : '❌ FAIL'}`);
        
        const allPassed = frontendAccess && backendServices && authFlow && staticAssets;
        console.log(`\n${allPassed ? '🎉 All tests passed!' : '⚠️  Some tests failed'}`);
        
        if (!allPassed) {
            console.log('\n💡 Troubleshooting tips:');
            console.log('- Make sure all services are running: docker-compose up -d');
            console.log('- Check service logs: docker-compose logs [service-name]');
            console.log('- Verify network connectivity between containers');
        }
        
    } catch (error) {
        console.error('💥 Test suite failed:', error.message);
        process.exit(1);
    }
}

// Run tests if this script is executed directly
if (require.main === module) {
    runTests();
}

module.exports = { 
    runTests, 
    testFrontendAccess, 
    testBackendServices, 
    testAuthFlow, 
    testStaticAssets 
};
