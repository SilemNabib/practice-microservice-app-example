# ===========================================
# JENKINS MODULE OUTPUTS
# ===========================================

output "jenkins_config_file" {
  description = "Path to generated Jenkins configuration file"
  value       = local_file.jenkins_config.filename
}

output "jenkins_plugins_file" {
  description = "Path to generated Jenkins plugins file"
  value       = local_file.jenkins_plugins.filename
}

output "jenkins_docker_compose_file" {
  description = "Path to generated Jenkins Docker Compose file"
  value       = local_file.jenkins_docker_compose.filename
}

output "jenkins_configuration" {
  description = "Jenkins configuration summary"
  value = {
    port              = var.jenkins_port
    admin_user        = var.jenkins_admin_user
    admin_password_set = var.jenkins_admin_password != "" ? true : false
    terraform_version = var.terraform_version
  }
}

output "deployment_instructions" {
  description = "Instructions for deploying Jenkins"
  value = <<-EOT
    To deploy Jenkins with the generated configuration:
    
    1. Copy the generated files to your deployment directory:
       cp ${local_file.jenkins_config.filename} ./jenkins.yaml
       cp ${local_file.jenkins_plugins.filename} ./plugins.txt
       cp ${local_file.jenkins_docker_compose.filename} ./jenkins-docker-compose.yml
       cp ${local_file.docker_socket_fix.filename} ./docker-socket-fix.sh
       chmod +x ./docker-socket-fix.sh
    
    2. Deploy using Docker Compose:
       docker-compose -f jenkins-docker-compose.yml up -d
    
    3. Wait for Jenkins to start (check logs):
       docker-compose -f jenkins-docker-compose.yml logs -f jenkins
    
    4. Access Jenkins:
       http://localhost:${var.jenkins_port}
       Username: ${var.jenkins_admin_user}
       Password: [check container logs for initial password]
  EOT
}