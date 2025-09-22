# ===========================================
# REDIS MODULE VARIABLES
# ===========================================

# ===========================================
# DEPLOYMENT CONFIGURATION
# ===========================================

variable "deployment_phase" {
  description = "Deployment phase: 'local' for Docker, 'cloud' for AWS ElastiCache"
  type        = string
  
  validation {
    condition     = contains(["local", "cloud"], var.deployment_phase)
    error_message = "Deployment phase must be either 'local' or 'cloud'."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

# ===========================================
# NETWORKING CONFIGURATION
# ===========================================

variable "network_name" {
  description = "Docker network name (local only)"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID for AWS ElastiCache (cloud only)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for AWS ElastiCache (cloud only)"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Redis (cloud only)"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# ===========================================
# REDIS CONFIGURATION
# ===========================================

variable "redis_version" {
  description = "Redis version for Docker image"
  type        = string
  default     = "7.0-alpine"
}

variable "redis_port" {
  description = "Redis port for external access"
  type        = number
  default     = 6379
}

variable "redis_password" {
  description = "Redis password for authentication"
  type        = string
  default     = "redis123"
  sensitive   = true
}

# ===========================================
# MEMORY CONFIGURATION
# ===========================================

variable "redis_memory_limit" {
  description = "Redis memory limit"
  type        = string
  default     = "256mb"
}

variable "redis_memory_policy" {
  description = "Redis memory eviction policy when memory limit is reached"
  type        = string
  default     = "allkeys-lru"
  
  validation {
    condition = contains([
      "noeviction",
      "allkeys-lru",
      "volatile-lru",
      "allkeys-random",
      "volatile-random",
      "volatile-ttl"
    ], var.redis_memory_policy)
    error_message = "Memory policy must be one of: noeviction, allkeys-lru, volatile-lru, allkeys-random, volatile-random, volatile-ttl."
  }
}

variable "maxmemory_samples" {
  description = "Number of samples for LRU eviction"
  type        = number
  default     = 5
}

# ===========================================
# CONNECTION CONFIGURATION
# ===========================================

variable "tcp_keepalive" {
  description = "TCP keepalive timeout in seconds"
  type        = number
  default     = 300
}

variable "timeout" {
  description = "Client timeout in seconds"
  type        = number
  default     = 0
}

# ===========================================
# AWS ELASTICACHE CONFIGURATION (Cloud Only)
# ===========================================

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "parameter_group_name" {
  description = "ElastiCache parameter group name"
  type        = string
  default     = "default.redis7"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters"
  type        = number
  default     = 1
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}

# ===========================================
# BACKUP CONFIGURATION (Cloud Only)
# ===========================================

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 1
}

variable "snapshot_window" {
  description = "Daily time range for snapshots (HH:MM-HH:MM)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance (ddd:HH:MM-ddd:HH:MM)"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

# ===========================================
# MONITORING CONFIGURATION
# ===========================================

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# ===========================================
# TAGS
# ===========================================

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ===========================================
# CACHE ASIDE PATTERN CONFIGURATION
# ===========================================

variable "cache_ttl_default" {
  description = "Default TTL for cached items in seconds"
  type        = number
  default     = 300  # 5 minutes
}

variable "cache_ttl_user_data" {
  description = "TTL for user data cache in seconds"
  type        = number
  default     = 600  # 10 minutes
}

variable "cache_ttl_todo_data" {
  description = "TTL for TODO data cache in seconds"
  type        = number
  default     = 180  # 3 minutes
}

variable "enable_cache_warming" {
  description = "Enable cache warming for frequently accessed data"
  type        = bool
  default     = false
}

variable "cache_warming_schedule" {
  description = "Cron schedule for cache warming (local only)"
  type        = string
  default     = "0 */6 * * *"  # Every 6 hours
}
