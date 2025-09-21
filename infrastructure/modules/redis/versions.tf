# ===========================================
# PROVIDER REQUIREMENTS - REDIS MODULE
# ===========================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    # Docker provider for local deployment
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.4"
    }
    
    # AWS provider for cloud deployment - COMMENTED OUT FOR TESTING
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
    
    # Local provider for file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
