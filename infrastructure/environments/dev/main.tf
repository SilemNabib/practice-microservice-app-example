# ===========================================
# MICROSERVICES INFRASTRUCTURE - DEV ENVIRONMENT
# ===========================================

# Terraform version and provider requirements
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    # Docker provider removed - using Docker CLI directly in pipeline
    
  # AWS provider for cloud deployment (Phase 2) - COMMENTED OUT FOR TESTING
  # aws = {
  #   source  = "hashicorp/aws"
  #   version = "~> 5.0"
  # }
  
    # Local provider for file generation
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0, ~> 2.4"
    }
    
    # Random provider for generating unique identifiers
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# ===========================================
# PROVIDER CONFIGURATIONS
# ===========================================

# Docker provider removed - using Docker CLI directly in pipeline

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
}

# ===========================================
# MODULE CALLS - CONFIGURATION GENERATION
# ===========================================

# Redis module for Cache Aside pattern configuration
module "redis" {
  source = "../../modules/redis"
  
  # Project configuration
  project_name = local.project_name
  environment  = local.environment
  
  # Deployment phase
  deployment_phase = "local"
  
  # Redis configuration
  redis_version     = var.redis_version
  redis_password    = var.redis_password
  redis_port        = var.redis_port
  
  # Cache Aside Pattern TTL settings
  cache_ttl_default   = var.cache_ttl_default
  cache_ttl_todo_data = var.cache_ttl_todo_data
  cache_ttl_user_data = var.cache_ttl_user_data
}

# Jenkins module for CI/CD configuration
module "jenkins" {
  source = "../../modules/jenkins"
  
  # Project configuration
  project_name = local.project_name
  environment  = local.environment
  
  # Jenkins configuration
  jenkins_version    = var.jenkins_version
  jenkins_port       = var.jenkins_port
  jenkins_url        = var.jenkins_url
  jenkins_admin_user = var.jenkins_admin_user
  jenkins_admin_password = var.jenkins_admin_password
  
  # Terraform configuration
  terraform_version = var.terraform_version
}

# ===========================================
# OUTPUTS
# ===========================================

output "redis_config_file" {
  description = "Path to generated Redis configuration file"
  value       = module.redis.redis_config_file
}

output "jenkins_config_file" {
  description = "Path to generated Jenkins configuration file"
  value       = module.jenkins.jenkins_config_file
}

output "infrastructure_status" {
  description = "Status of infrastructure configuration generation"
  value       = "Configuration files generated successfully"
}