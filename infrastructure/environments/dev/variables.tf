# ===========================================
# VARIABLES - DEVELOPMENT ENVIRONMENT
# ===========================================

# ===========================================
# DEPLOYMENT CONFIGURATION
# ===========================================

variable "deployment_phase" {
  description = "Deployment phase: 'local' for Docker Swarm, 'cloud' for AWS"
  type        = string
  default     = "local"
  
  validation {
    condition     = contains(["local", "cloud"], var.deployment_phase)
    error_message = "Deployment phase must be either 'local' or 'cloud'."
  }
}

# ===========================================
# AWS CONFIGURATION (Phase 2 - Cloud)
# ===========================================

variable "aws_region" {
  description = "AWS region for cloud deployment"
  type        = string
  default     = "us-west-2"
}

variable "aws_availability_zones" {
  description = "AWS availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

# ===========================================
# DOCKER CONFIGURATION (Phase 1 - Local)
# ===========================================

variable "docker_network_subnet" {
  description = "Docker network subnet for local development"
  type        = string
  default     = "192.168.100.0/24"
}

variable "docker_host" {
  description = "Docker host for local development"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "docker_socket_user" {
  description = "User ID for Docker socket access (auto-detected)"
  type        = string
  default     = "0"
}

variable "docker_socket_group" {
  description = "Group ID for Docker socket access (auto-detected)"
  type        = string
  default     = "0"
}

# ===========================================
# REDIS CONFIGURATION
# ===========================================

variable "redis_version" {
  description = "Redis Docker image version"
  type        = string
  default     = "7.0-alpine"
}

variable "redis_port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "redis_password" {
  description = "Redis password for authentication"
  type        = string
  default     = "redis123"
  sensitive   = true
}

variable "redis_memory_limit" {
  description = "Redis memory limit"
  type        = string
  default     = "256mb"
}

variable "redis_memory_policy" {
  description = "Redis memory eviction policy"
  type        = string
  default     = "allkeys-lru"
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

# ===========================================
# JENKINS CONFIGURATION
# ===========================================

variable "jenkins_version" {
  description = "Jenkins Docker image version"
  type        = string
  default     = "lts-jdk17"
}

variable "jenkins_port" {
  description = "Jenkins web interface port"
  type        = number
  default     = 8080
}

variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "terraform_version" {
  description = "Terraform version to install in Jenkins"
  type        = string
  default     = "1.6.0"
}

# ===========================================
# NETWORKING CONFIGURATION
# ===========================================

variable "vpc_cidr_block" {
  description = "CIDR block for VPC (cloud phase)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# ===========================================
# KUBERNETES CONFIGURATION (Phase 2 - Cloud)
# ===========================================

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "microservices-dev"
}

variable "eks_node_group_name" {
  description = "EKS node group name"
  type        = string
  default     = "microservices-nodes"
}

variable "eks_node_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_size" {
  description = "EKS node desired size"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "EKS node minimum size"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "EKS node maximum size"
  type        = number
  default     = 4
}

# ===========================================
# MONITORING AND LOGGING
# ===========================================

variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana)"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging stack (ELK, Fluentd)"
  type        = bool
  default     = true
}

# ===========================================
# SECURITY CONFIGURATION
# ===========================================

variable "enable_ssl" {
  description = "Enable SSL/TLS for services"
  type        = bool
  default     = false
}

variable "ssl_certificate_arn" {
  description = "SSL certificate ARN (AWS only)"
  type        = string
  default     = ""
}

# ===========================================
# TAGS
# ===========================================

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ===========================================
# ENVIRONMENT SPECIFIC
# ===========================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "microservices"
}
