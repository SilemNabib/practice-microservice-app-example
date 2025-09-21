# ===========================================
# JENKINS MODULE OUTPUTS
# ===========================================

# ===========================================
# DOCKER OUTPUTS (Phase 1 - Local)
# ===========================================

output "jenkins_container_name" {
  description = "Name of the Jenkins container"
  value       = var.deployment_phase == "local" ? docker_container.jenkins[0].name : "jenkins-not-deployed-locally"
}

output "jenkins_container_id" {
  description = "ID of the Jenkins container"
  value       = var.deployment_phase == "local" ? docker_container.jenkins[0].id : "jenkins-not-deployed-locally"
}

output "jenkins_endpoint" {
  description = "Jenkins endpoint URL"
  value       = var.deployment_phase == "local" ? "http://localhost:${var.jenkins_port}" : "jenkins-not-deployed-locally"
}

output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = var.jenkins_admin_user
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = var.jenkins_admin_password
  sensitive   = true
}

output "jenkins_data_volume" {
  description = "Jenkins data volume name"
  value       = var.deployment_phase == "local" ? docker_volume.jenkins_data[0].name : "jenkins-volume-not-deployed-locally"
}

output "jenkins_plugins_volume" {
  description = "Jenkins plugins volume name"
  value       = var.deployment_phase == "local" ? docker_volume.jenkins_plugins[0].name : "jenkins-plugins-volume-not-deployed-locally"
}

# ===========================================
# AWS OUTPUTS (Phase 2 - Cloud) - COMMENTED OUT FOR TESTING
# ===========================================

# output "jenkins_ecs_task_definition_arn" {
#   description = "ARN of the Jenkins ECS task definition"
#   value       = var.deployment_phase == "cloud" ? aws_ecs_task_definition.jenkins[0].arn : "jenkins-ecs-not-deployed-cloud"
# }

# output "jenkins_cloudwatch_log_group" {
#   description = "CloudWatch log group name for Jenkins"
#   value       = var.deployment_phase == "cloud" ? aws_cloudwatch_log_group.jenkins[0].name : "jenkins-logs-not-deployed-cloud"
# }

# ===========================================
# GENERAL OUTPUTS
# ===========================================

output "jenkins_version" {
  description = "Jenkins version deployed"
  value       = var.jenkins_version
}

output "terraform_version" {
  description = "Terraform version configured in Jenkins"
  value       = var.terraform_version
}

output "deployment_phase" {
  description = "Current deployment phase"
  value       = var.deployment_phase
}
