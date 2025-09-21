# ===========================================
# REDIS MODULE OUTPUTS
# ===========================================

# ===========================================
# CONNECTION INFORMATION
# ===========================================

output "endpoint" {
  description = "Redis connection endpoint"
  value = var.deployment_phase == "local" ? "localhost:${var.redis_port}" : "aws-endpoint-not-configured"
}

output "port" {
  description = "Redis connection port"
  value = var.deployment_phase == "local" ? var.redis_port : 6379
}

output "host" {
  description = "Redis host address"
  value = var.deployment_phase == "local" ? "localhost" : "aws-host-not-configured"
}

# ===========================================
# AUTHENTICATION INFORMATION
# ===========================================

output "password" {
  description = "Redis password for authentication"
  value = var.redis_password
  sensitive = true
}

output "auth_string" {
  description = "Complete Redis connection string with authentication"
  value = var.deployment_phase == "local" ? "redis://:${var.redis_password}@localhost:${var.redis_port}" : "redis://aws-not-configured"
  sensitive = true
}

# ===========================================
# DOCKER INFORMATION (Local Only)
# ===========================================

output "container_name" {
  description = "Docker container name (local only)"
  value = var.deployment_phase == "local" ? docker_container.redis[0].name : null
}

output "container_id" {
  description = "Docker container ID (local only)"
  value = var.deployment_phase == "local" ? docker_container.redis[0].id : null
}

output "volume_name" {
  description = "Docker volume name for data persistence (local only)"
  value = var.deployment_phase == "local" ? docker_volume.redis_data[0].name : null
}

output "image_id" {
  description = "Docker image ID (local only)"
  value = var.deployment_phase == "local" ? docker_image.redis[0].id : null
}

# ===========================================
# AWS ELASTICACHE INFORMATION (Cloud Only) - COMMENTED OUT FOR TESTING
# ===========================================

# output "cluster_id" {
#   description = "ElastiCache cluster ID (cloud only)"
#   value = var.deployment_phase == "cloud" ? aws_elasticache_replication_group.redis[0].id : null
# }

# output "cluster_arn" {
#   description = "ElastiCache cluster ARN (cloud only)"
#   value = var.deployment_phase == "cloud" ? aws_elasticache_replication_group.redis[0].arn : null
# }

# output "primary_endpoint" {
#   description = "ElastiCache primary endpoint (cloud only)"
#   value = var.deployment_phase == "cloud" ? aws_elasticache_replication_group.redis[0].primary_endpoint_address : null
# }

# output "reader_endpoint" {
#   description = "ElastiCache reader endpoint (cloud only)"
#   value = var.deployment_phase == "cloud" ? aws_elasticache_replication_group.redis[0].reader_endpoint_address : null
# }

# output "security_group_id" {
#   description = "Security group ID for Redis (cloud only)"
#   value = var.deployment_phase == "cloud" ? aws_security_group.redis[0].id : null
# }

# output "subnet_group_name" {
#   description = "ElastiCache subnet group name (cloud only)"
#   value = var.deployment_phase == "cloud" ? aws_elasticache_subnet_group.redis[0].name : null
# }

# ===========================================
# CONFIGURATION INFORMATION
# ===========================================

output "redis_version" {
  description = "Redis version being used"
  value = var.redis_version
}

output "memory_limit" {
  description = "Redis memory limit configuration"
  value = var.redis_memory_limit
}

output "memory_policy" {
  description = "Redis memory eviction policy"
  value = var.redis_memory_policy
}

# ===========================================
# CACHE ASIDE PATTERN INFORMATION
# ===========================================

output "cache_ttl_config" {
  description = "Cache TTL configuration for Cache Aside pattern"
  value = {
    default = var.cache_ttl_default
    user_data = var.cache_ttl_user_data
    todo_data = var.cache_ttl_todo_data
  }
}

output "cache_warming_enabled" {
  description = "Cache warming configuration"
  value = var.enable_cache_warming
}

output "cache_warming_schedule" {
  description = "Cache warming schedule (local only)"
  value = var.deployment_phase == "local" ? var.cache_warming_schedule : null
}

# ===========================================
# MONITORING INFORMATION
# ===========================================

# output "log_group_name" {
#   description = "CloudWatch log group name (cloud only)"
#   value = var.deployment_phase == "cloud" ? aws_cloudwatch_log_group.redis[0].name : null
# }

output "health_check_command" {
  description = "Redis health check command"
  value = var.deployment_phase == "local" ? "redis-cli --no-auth-warning -a ${var.redis_password} ping" : "redis-cli -h aws-host-not-configured -a ${var.redis_password} ping"
}

# ===========================================
# ENVIRONMENT INFORMATION
# ===========================================

output "environment" {
  description = "Environment name"
  value = var.environment
}

output "project_name" {
  description = "Project name"
  value = var.project_name
}

output "deployment_phase" {
  description = "Current deployment phase"
  value = var.deployment_phase
}

# ===========================================
# CONNECTION EXAMPLES
# ===========================================

output "connection_examples" {
  description = "Examples of how to connect to Redis"
  value = {
    docker_local = var.deployment_phase == "local" ? {
      command = "docker exec -it ${docker_container.redis[0].name} redis-cli -a ${var.redis_password}"
      url = "redis://localhost:${var.redis_port}"
    } : null
    
    aws_cloud = var.deployment_phase == "cloud" ? {
      endpoint = "aws-endpoint-not-configured"
      port = 6379
      url = "redis://aws-endpoint-not-configured:6379"
    } : null
    
    application_config = {
      host = var.deployment_phase == "local" ? "localhost" : "aws-host-not-configured"
      port = var.deployment_phase == "local" ? var.redis_port : 6379
      password = var.redis_password
    }
  }
}
