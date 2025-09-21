# ===========================================
# TERRAFORM VARIABLES - DEVELOPMENT ENVIRONMENT
# ===========================================

# ===========================================
# DEPLOYMENT CONFIGURATION
# ===========================================

# Start with local deployment (Docker Swarm)
deployment_phase = "local"

# ===========================================
# AWS CONFIGURATION (Phase 2 - Cloud)
# ===========================================

# AWS region for cloud deployment
aws_region = "us-west-2"

# AWS availability zones
aws_availability_zones = ["us-west-2a", "us-west-2b"]

# ===========================================
# DOCKER CONFIGURATION (Phase 1 - Local)
# ===========================================

# Docker network configuration
docker_network_subnet = "192.168.100.0/24"
# Docker host - automatically detects Docker Desktop or Colima
# Docker Desktop: "unix:///var/run/docker.sock"
# Colima: "unix:///Users/USERNAME/.colima/docker.sock"
docker_host = "unix:///Users/santiago/.colima/docker.sock"

# ===========================================
# REDIS CONFIGURATION
# ===========================================

# Redis version and configuration
redis_version = "7.0-alpine"
redis_port = 6379
redis_memory_limit = "256mb"
redis_memory_policy = "allkeys-lru"

# ===========================================
# JENKINS CONFIGURATION
# ===========================================

# Jenkins version and configuration
jenkins_version = "lts-jdk17"
jenkins_port = 8080

# Jenkins admin credentials (CHANGE IN PRODUCTION!)
jenkins_admin_user = "admin"
jenkins_admin_password = "admin123"

# ===========================================
# NETWORKING CONFIGURATION
# ===========================================

# VPC configuration for cloud deployment
vpc_cidr_block = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# ===========================================
# KUBERNETES CONFIGURATION (Phase 2 - Cloud)
# ===========================================

# EKS cluster configuration
eks_cluster_name = "microservices-dev"
eks_node_group_name = "microservices-nodes"
eks_node_instance_type = "t3.medium"
eks_node_desired_size = 2
eks_node_min_size = 1
eks_node_max_size = 4

# ===========================================
# MONITORING AND LOGGING
# ===========================================

# Enable monitoring and logging for development
enable_monitoring = true
enable_logging = true

# ===========================================
# SECURITY CONFIGURATION
# ===========================================

# SSL configuration (disabled for local development)
enable_ssl = false
ssl_certificate_arn = ""

# ===========================================
# ENVIRONMENT SPECIFIC
# ===========================================

# Environment and project configuration
environment = "dev"
project_name = "microservices"

# ===========================================
# ADDITIONAL TAGS
# ===========================================

# Additional tags for development environment
additional_tags = {
  Environment = "development"
  Owner       = "devops-team"
  CostCenter  = "engineering"
  Project     = "microservices-training"
}
