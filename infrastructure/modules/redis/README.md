# Redis Module - Cache Aside Pattern

This Terraform module deploys Redis with the **Cache Aside pattern** implementation, supporting both local Docker deployment and AWS ElastiCache for cloud environments.

## 🎯 Overview

The Redis module implements the **Cache Aside pattern** (also known as **Lazy Loading**), which is a cloud design pattern that improves application performance by caching frequently accessed data.

### Cache Aside Pattern Flow

```
Application Request
        ↓
    Check Cache
        ↓
   Cache Hit? → Yes → Return Cached Data
        ↓ No
   Query Database
        ↓
   Store in Cache
        ↓
   Return Data
```

## 🏗️ Architecture

### Local Deployment (Docker)
- **Redis Container**: Single Redis instance with Docker
- **Data Persistence**: Docker volume for data persistence
- **Network**: Docker bridge network
- **Health Checks**: Built-in health monitoring

### Cloud Deployment (AWS ElastiCache)
- **Redis Cluster**: Managed Redis cluster
- **High Availability**: Multi-AZ deployment option
- **Security**: VPC security groups
- **Monitoring**: CloudWatch integration

## 📋 Features

### ✅ Core Features
- **Dual Deployment**: Local (Docker) and Cloud (AWS ElastiCache)
- **Cache Aside Pattern**: Implemented with configurable TTL
- **Data Persistence**: Redis AOF (Append Only File)
- **Security**: Password authentication
- **Health Monitoring**: Built-in health checks
- **Memory Management**: Configurable memory limits and eviction policies

### ✅ Cache Aside Implementation
- **Configurable TTL**: Different TTL for different data types
- **Cache Warming**: Optional cache warming for frequently accessed data
- **Memory Policies**: LRU, LFU, and other eviction strategies
- **Connection Pooling**: Optimized connection management

## 🚀 Usage

### Basic Usage

```hcl
module "redis" {
  source = "../../modules/redis"
  
  # Basic configuration
  environment = "dev"
  project_name = "microservices"
  
  # Deployment phase
  deployment_phase = "local"  # or "cloud"
  
  # Network configuration (local only)
  network_name = "microservices-network"
  
  # Common tags
  tags = {
    Environment = "dev"
    Project     = "microservices"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Usage

```hcl
module "redis" {
  source = "../../modules/redis"
  
  # Basic configuration
  environment = "prod"
  project_name = "microservices"
  deployment_phase = "cloud"
  
  # Redis configuration
  redis_version = "7.0-alpine"
  redis_password = "secure-password-123"
  redis_memory_limit = "1gb"
  redis_memory_policy = "allkeys-lru"
  
  # Cache Aside pattern configuration
  cache_ttl_default = 300      # 5 minutes
  cache_ttl_user_data = 600    # 10 minutes
  cache_ttl_todo_data = 180    # 3 minutes
  enable_cache_warming = true
  cache_warming_schedule = "0 */6 * * *"  # Every 6 hours
  
  # AWS configuration (cloud only)
  vpc_id = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]
  allowed_cidr_blocks = ["10.0.0.0/8"]
  
  # ElastiCache configuration
  node_type = "cache.t3.medium"
  num_cache_clusters = 2
  automatic_failover_enabled = true
  multi_az_enabled = true
  
  # Monitoring
  log_retention_days = 30
  
  # Tags
  tags = {
    Environment = "prod"
    Project     = "microservices"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
  }
}
```

## 📊 Outputs

The module provides comprehensive outputs for integration with other modules:

### Connection Information
- `endpoint`: Redis connection endpoint
- `port`: Redis connection port
- `host`: Redis host address
- `password`: Redis authentication password
- `auth_string`: Complete connection string with authentication

### Docker Information (Local Only)
- `container_name`: Docker container name
- `container_id`: Docker container ID
- `volume_name`: Docker volume name for data persistence
- `image_id`: Docker image ID

### AWS Information (Cloud Only)
- `cluster_id`: ElastiCache cluster ID
- `cluster_arn`: ElastiCache cluster ARN
- `primary_endpoint`: Primary endpoint for writes
- `reader_endpoint`: Reader endpoint for reads
- `security_group_id`: Security group ID
- `subnet_group_name`: Subnet group name

### Configuration Information
- `redis_version`: Redis version being used
- `memory_limit`: Redis memory limit
- `memory_policy`: Redis memory eviction policy
- `cache_ttl_config`: Cache TTL configuration
- `connection_examples`: Usage examples

## 🔧 Configuration

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `environment` | Environment name (dev, staging, prod) | `string` |
| `project_name` | Project name for resource naming | `string` |
| `deployment_phase` | Deployment phase: "local" or "cloud" | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `redis_version` | Redis version | `string` | `"7.0-alpine"` |
| `redis_port` | Redis port | `number` | `6379` |
| `redis_password` | Redis password | `string` | `"redis123"` |
| `redis_memory_limit` | Memory limit | `string` | `"256mb"` |
| `redis_memory_policy` | Memory eviction policy | `string` | `"allkeys-lru"` |

### Cache Aside Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cache_ttl_default` | Default TTL in seconds | `number` | `300` |
| `cache_ttl_user_data` | User data TTL in seconds | `number` | `600` |
| `cache_ttl_todo_data` | TODO data TTL in seconds | `number` | `180` |
| `enable_cache_warming` | Enable cache warming | `bool` | `false` |
| `cache_warming_schedule` | Cache warming schedule | `string` | `"0 */6 * * *"` |

## 🔍 Cache Aside Pattern Implementation

### How It Works

1. **Application Request**: User requests data
2. **Cache Check**: Application checks Redis cache first
3. **Cache Hit**: If data exists and is fresh, return cached data
4. **Cache Miss**: If data doesn't exist or is expired:
   - Query the database
   - Store result in Redis cache with TTL
   - Return data to user

### TTL Strategy

Different data types have different TTL values:

- **User Data**: 10 minutes (changes infrequently)
- **TODO Data**: 3 minutes (changes more frequently)
- **Default**: 5 minutes (general purpose)

### Memory Management

- **Memory Limit**: Configurable memory limit per environment
- **Eviction Policy**: `allkeys-lru` (Least Recently Used)
- **Persistence**: AOF (Append Only File) for data durability

## 🧪 Testing

### Local Testing

```bash
# Connect to Redis container
docker exec -it microservices-redis-dev redis-cli -a redis123

# Test basic operations
redis-cli -a redis123 ping
redis-cli -a redis123 set test "Hello World"
redis-cli -a redis123 get test
redis-cli -a redis123 expire test 60
redis-cli -a redis123 ttl test

# Test Cache Aside pattern
redis-cli -a redis123 set user:1 '{"id":1,"name":"John"}' EX 600
redis-cli -a redis123 get user:1
```

### Cloud Testing

```bash
# Connect to ElastiCache
redis-cli -h your-cluster-endpoint -a your-password

# Test operations (same as local)
redis-cli -h endpoint -a password ping
```

## 📈 Monitoring

### Local Monitoring

```bash
# Check container status
docker ps | grep redis

# Check container logs
docker logs microservices-redis-dev

# Check resource usage
docker stats microservices-redis-dev
```

### Cloud Monitoring

- **CloudWatch Metrics**: CPU, memory, connections
- **CloudWatch Logs**: Redis logs and errors
- **ElastiCache Metrics**: Cache hits/misses, evictions

## 🔒 Security

### Authentication
- **Password Protection**: All Redis instances require authentication
- **Network Security**: VPC security groups (cloud)
- **Encryption**: In-transit encryption (cloud)

### Best Practices
- **Strong Passwords**: Use complex passwords
- **Network Isolation**: Use private subnets (cloud)
- **Access Control**: Limit access to necessary services only

## 🚨 Troubleshooting

### Common Issues

#### Connection Refused
```bash
# Check if container is running
docker ps | grep redis

# Check container logs
docker logs microservices-redis-dev

# Restart container
docker restart microservices-redis-dev
```

#### Authentication Failed
```bash
# Verify password
redis-cli -a correct-password ping

# Check Redis configuration
docker exec -it microservices-redis-dev redis-cli config get requirepass
```

#### Memory Issues
```bash
# Check memory usage
redis-cli -a password info memory

# Check eviction policy
redis-cli -a password config get maxmemory-policy

# Clear cache if needed
redis-cli -a password flushall
```

## 📚 Examples

### Application Integration

#### Node.js Example
```javascript
const redis = require('redis');
const client = redis.createClient({
  host: 'localhost',
  port: 6379,
  password: 'redis123'
});

// Cache Aside pattern implementation
async function getUserData(userId) {
  // 1. Check cache first
  const cached = await client.get(`user:${userId}`);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // 2. Cache miss - query database
  const userData = await database.getUser(userId);
  
  // 3. Store in cache with TTL
  await client.setex(`user:${userId}`, 600, JSON.stringify(userData));
  
  return userData;
}
```

#### Python Example
```python
import redis
import json

client = redis.Redis(host='localhost', port=6379, password='redis123')

def get_user_data(user_id):
    # 1. Check cache first
    cached = client.get(f'user:{user_id}')
    if cached:
        return json.loads(cached)
    
    # 2. Cache miss - query database
    user_data = database.get_user(user_id)
    
    # 3. Store in cache with TTL
    client.setex(f'user:{user_id}', 600, json.dumps(user_data))
    
    return user_data
```

## 🏷️ Tags

All resources are tagged with:
- `Environment`: Environment name
- `Project`: Project name
- `ManagedBy`: "terraform"
- Additional custom tags

## 📄 License

This module is part of the microservices infrastructure project.

---

**Last Updated**: $(date)  
**Version**: 1.0  
**Owner**: DevOps Team
