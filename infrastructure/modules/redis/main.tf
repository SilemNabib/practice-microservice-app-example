# ===========================================
# REDIS MODULE - CACHE ASIDE PATTERN
# ===========================================

# ===========================================
# DOCKER IMAGE (Phase 1 - Local)
# ===========================================

# Pull Redis Docker image
resource "docker_image" "redis" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  name = "redis:${var.redis_version}"
  
  keep_locally = true  # Keep image even if not used
}

# ===========================================
# DOCKER VOLUME (Phase 1 - Local)
# ===========================================

# Create volume for Redis data persistence
resource "docker_volume" "redis_data" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  name = "${var.project_name}-redis-${var.environment}-data"
}

# ===========================================
# DOCKER CONTAINER (Phase 1 - Local)
# ===========================================

# Create Redis container
resource "docker_container" "redis" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  name  = "${var.project_name}-redis-${var.environment}"
  image = docker_image.redis[0].image_id
  
  # Container configuration
  restart = "unless-stopped"
  
  # Port mapping
  ports {
    internal = 6379
    external = var.redis_port
  }
  
  # Volume mounting for data persistence
  volumes {
    volume_name    = docker_volume.redis_data[0].name
    container_path = "/data"
  }
  
  # Environment variables
  env = [
    "REDIS_PASSWORD=${var.redis_password}",
  ]
  
  # Command with Redis configuration
  command = [
    "redis-server",
    "--appendonly", "yes",                    # Enable persistence
    "--maxmemory", var.redis_memory_limit,    # Memory limit
    "--maxmemory-policy", var.redis_memory_policy,  # Eviction policy
    "--requirepass", var.redis_password       # Set password
  ]
  
  # Health check
  healthcheck {
    test     = ["CMD", "redis-cli", "--no-auth-warning", "-a", var.redis_password, "ping"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
  
  # Network configuration
  networks_advanced {
    name = var.network_name
  }
}

# ===========================================
# AWS ELASTICACHE REDIS (Phase 2 - Cloud) - COMMENTED OUT FOR TESTING
# ===========================================

# ElastiCache subnet group - COMMENTED OUT FOR TESTING
# resource "aws_elasticache_subnet_group" "redis" {
#   count = var.deployment_phase == "cloud" ? 1 : 0
#   
#   name       = "${var.project_name}-redis-${var.environment}-subnet-group"
#   subnet_ids = var.subnet_ids
#   
#   tags = var.tags
# }

# ElastiCache security group - COMMENTED OUT FOR TESTING
# resource "aws_security_group" "redis" {
#   count = var.deployment_phase == "cloud" ? 1 : 0
#   
#   name_prefix = "${var.project_name}-redis-${var.environment}-"
#   vpc_id      = var.vpc_id
#   
#   # Allow Redis access from application servers
#   ingress {
#     from_port   = 6379
#     to_port     = 6379
#     protocol    = "tcp"
#     cidr_blocks = var.allowed_cidr_blocks
#   }
#   
#   # Allow outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   
#   tags = merge(var.tags, {
#     Name = "${var.project_name}-redis-${var.environment}-sg"
#   })
#   
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# ElastiCache Redis cluster - COMMENTED OUT FOR TESTING
# resource "aws_elasticache_replication_group" "redis" {
#   count = var.deployment_phase == "cloud" ? 1 : 0
#   
#   # Basic configuration
#   replication_group_id         = "${var.project_name}-redis-${var.environment}"
#   description                  = "Redis cluster for ${var.project_name} ${var.environment}"
#   
#   # Node configuration
#   node_type                   = var.node_type
#   port                        = 6379
#   parameter_group_name        = var.parameter_group_name
#   
#   # Cluster configuration
#   num_cache_clusters          = var.num_cache_clusters
#   automatic_failover_enabled  = var.automatic_failover_enabled
#   multi_az_enabled           = var.multi_az_enabled
#   
#   # Security configuration
#   subnet_group_name  = aws_elasticache_subnet_group.redis[0].name
#   security_group_ids = [aws_security_group.redis[0].id]
#   auth_token         = var.redis_password
#   
#   # Backup configuration
#   snapshot_retention_limit = var.snapshot_retention_limit
#   snapshot_window         = var.snapshot_window
#   
#   # Maintenance window
#   maintenance_window = var.maintenance_window
#   
#   # Tags
#   tags = var.tags
#   
#   # Apply immediately for development
#   apply_immediately = true
# }

# ===========================================
# REDIS CONFIGURATION FOR CACHE ASIDE PATTERN
# ===========================================

# Create Redis configuration file for Cache Aside pattern - COMMENTED OUT FOR TESTING
# resource "local_file" "redis_cache_aside_config" {
#   count = var.deployment_phase == "local" ? 1 : 0
#   
#   filename = "${path.module}/cache-aside-config.conf"
#   content = templatefile("${path.module}/cache-aside-config.conf.tpl", {
#     redis_password      = var.redis_password
#     memory_limit        = var.redis_memory_limit
#     memory_policy       = var.redis_memory_policy
#     maxmemory_samples   = var.maxmemory_samples
#     tcp_keepalive       = var.tcp_keepalive
#     timeout             = var.timeout
#   })
# }

# ===========================================
# MONITORING AND LOGGING
# ===========================================

# CloudWatch log group for Redis (cloud only) - COMMENTED OUT FOR TESTING
# resource "aws_cloudwatch_log_group" "redis" {
#   count = var.deployment_phase == "cloud" ? 1 : 0
#   
#   name              = "/aws/elasticache/redis/${var.project_name}-${var.environment}"
#   retention_in_days = var.log_retention_days
#   
#   tags = var.tags
# }
