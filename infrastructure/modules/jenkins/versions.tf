# ===========================================
# JENKINS MODULE - PROVIDER REQUIREMENTS
# ===========================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    # Docker provider removed - using Docker CLI directly in pipeline
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    # AWS provider - COMMENTED OUT FOR TESTING
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
  }
}
