# ===========================================
# JENKINS MODULE VARIABLES
# ===========================================

# ===========================================
# DEPLOYMENT CONFIGURATION
# ===========================================

variable "deployment_phase" {
  description = "Deployment phase: local, cloud"
  type        = string
  default     = "local"
  
  validation {
    condition     = contains(["local", "cloud"], var.deployment_phase)
    error_message = "Deployment phase must be either 'local' or 'cloud'."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "microservices"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ===========================================
# JENKINS CONFIGURATION
# ===========================================

variable "jenkins_version" {
  description = "Jenkins version to use"
  type        = string
  default     = "lts-jdk17"
}

variable "jenkins_port" {
  description = "External port for Jenkins"
  type        = number
  default     = 8080
}

variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
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
# DOCKER CONFIGURATION
# ===========================================

variable "docker_host" {
  description = "Docker host for Jenkins to connect to"
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

variable "network_name" {
  description = "Docker network name for Jenkins"
  type        = string
  default     = "microservices-dev-network"
}

# ===========================================
# AWS CONFIGURATION (Phase 2 - Cloud)
# ===========================================

variable "aws_region" {
  description = "AWS region for cloud deployment"
  type        = string
  default     = "us-west-2"
}

variable "jenkins_cpu" {
  description = "CPU units for Jenkins ECS task"
  type        = string
  default     = "1024"
}

variable "jenkins_memory" {
  description = "Memory for Jenkins ECS task"
  type        = string
  default     = "2048"
}

variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 7
}

# ===========================================
# TAGGING
# ===========================================

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "microservices"
    ManagedBy   = "terraform"
  }
}
