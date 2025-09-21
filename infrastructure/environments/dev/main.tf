# ===========================================
# TERRAFORM CONFIGURATION - DEVELOPMENT ENVIRONMENT
# ===========================================

# Terraform version and provider requirements
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    # Docker provider for local development (Phase 1)
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.4"
    }
    
  # AWS provider for cloud deployment (Phase 2) - COMMENTED OUT FOR TESTING
  # aws = {
  #   source  = "hashicorp/aws"
  #   version = "~> 5.0"
  # }
    
    # Random provider for generating unique names
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# ===========================================
# PROVIDER CONFIGURATIONS
# ===========================================

# Docker provider configuration (Phase 1 - Local)
# Automatically detects Docker Desktop or Colima
provider "docker" {
  host = var.docker_host
}

# AWS provider configuration (Phase 2 - Cloud) - COMMENTED OUT FOR TESTING
# Note: AWS credentials should be configured via AWS CLI or environment variables
# provider "aws" {
#   region = var.aws_region
#   
#   # Only use AWS provider when phase is "cloud"
#   # This allows us to conditionally use providers
# }

# Random provider for generating unique identifiers
provider "random" {}

# ===========================================
# LOCAL VARIABLES
# ===========================================

locals {
  # Environment-specific naming
  environment = "dev"
  project_name = "microservices"
  
  # Common tags for all resources
  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
  
  # Network configuration
  network_name = "${local.project_name}-${local.environment}-network"
  
  # Container naming
  redis_container_name = "${local.project_name}-redis-${local.environment}"
  jenkins_container_name = "${local.project_name}-jenkins-${local.environment}"
}

# ===========================================
# DOCKER NETWORK (Phase 1 - Local)
# ===========================================

# Use existing Docker network for microservices communication
# (Created manually to avoid subnet conflicts)
# resource "docker_network" "microservices_network" {
#   count = var.deployment_phase == "local" ? 1 : 0
#   
#   name = local.network_name
#   driver = "bridge"
#   
#   ipam_config {
#     subnet = var.docker_network_subnet
#   }
# }

# Data source to reference existing network
data "docker_network" "microservices_network" {
  name = local.network_name
}

# ===========================================
# MODULE CALLS
# ===========================================

# Redis module (Cache Aside pattern)
module "redis" {
  source = "../../modules/redis"
  
  # Module variables
  environment = local.environment
  project_name = local.project_name
  network_name = var.deployment_phase == "local" ? data.docker_network.microservices_network.name : null
  
  # Deployment phase
  deployment_phase = var.deployment_phase
  
  # Redis configuration (from environment variables)
  redis_version = var.redis_version
  redis_port = var.redis_port
  redis_password = var.redis_password
  redis_memory_limit = var.redis_memory_limit
  redis_memory_policy = var.redis_memory_policy
  
  # Cache TTL configuration (from environment variables)
  cache_ttl_default = var.cache_ttl_default
  cache_ttl_user_data = var.cache_ttl_user_data
  cache_ttl_todo_data = var.cache_ttl_todo_data
  
  # Common tags
  tags = local.common_tags
  
    depends_on = [
      data.docker_network.microservices_network
    ]
}

# Docker Swarm module (Phase 1 - Local) - COMMENTED OUT FOR TESTING
# module "docker_swarm" {
#   count = var.deployment_phase == "local" ? 1 : 0
#   source = "../../modules/docker-swarm"
#   
#   # Module variables
#   environment = local.environment
#   project_name = local.project_name
#   network_name = data.docker_network.microservices_network.name
#   
#   # Common tags
#   tags = local.common_tags
#   
#   depends_on = [
#     docker_network.microservices_network
#   ]
# }

# Jenkins module (CI/CD with Terraform integration)
module "jenkins" {
  source = "../../modules/jenkins"
  
  # Module variables
  environment = local.environment
  project_name = local.project_name
  network_name = var.deployment_phase == "local" ? data.docker_network.microservices_network.name : null
  
  # Deployment phase
  deployment_phase = var.deployment_phase
  
  # Jenkins configuration (from environment variables)
  jenkins_version = var.jenkins_version
  jenkins_port = var.jenkins_port
  jenkins_admin_user = var.jenkins_admin_user
  jenkins_admin_password = var.jenkins_admin_password
  terraform_version = var.terraform_version
  
  # Docker configuration
  docker_host = var.docker_host
  docker_socket_user = var.docker_socket_user
  docker_socket_group = var.docker_socket_group
  
  # Common tags
  tags = local.common_tags
  
  depends_on = [
    data.docker_network.microservices_network
  ]
}

# ===========================================
# OUTPUTS
# ===========================================

output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "project_name" {
  description = "Project name"
  value       = local.project_name
}

output "network_name" {
  description = "Docker network name (local only)"
  value       = var.deployment_phase == "local" ? data.docker_network.microservices_network.name : null
}

output "redis_endpoint" {
  description = "Redis connection endpoint"
  value       = module.redis.endpoint
}

output "jenkins_endpoint" {
  description = "Jenkins access endpoint"
  value       = module.jenkins.jenkins_endpoint
}

output "deployment_phase" {
  description = "Current deployment phase"
  value       = var.deployment_phase
}
