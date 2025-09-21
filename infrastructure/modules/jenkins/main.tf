# ===========================================
# JENKINS MODULE - CONFIGURATION GENERATION
# ===========================================

# Generate Jenkins configuration file
resource "local_file" "jenkins_config" {
  content = templatefile("${path.module}/jenkins.yaml.tpl", {
    project_name       = var.project_name
    environment        = var.environment
    jenkins_port       = var.jenkins_port
    jenkins_admin_user = var.jenkins_admin_user
    terraform_version  = var.terraform_version
  })
  
  filename = "${path.module}/jenkins.yaml"
}

# Generate Jenkins plugins list
resource "local_file" "jenkins_plugins" {
  content = templatefile("${path.module}/plugins.txt.tpl", {
    project_name = var.project_name
    environment  = var.environment
  })
  
  filename = "${path.module}/plugins.txt"
}

# Generate Docker Compose configuration for Jenkins
resource "local_file" "jenkins_docker_compose" {
  content = <<-EOT
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:${var.jenkins_version}
    container_name: ${var.project_name}-jenkins-${var.environment}
    ports:
      - "${var.jenkins_port}:8080"
      - "50000:50000"
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock
      - JENKINS_OPTS=--httpPort=8080
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - ./jenkins.yaml:/var/jenkins_home/casc_configs/jenkins.yaml
      - ./plugins.txt:/var/jenkins_home/plugins.txt
      - ./docker-socket-fix.sh:/usr/local/bin/docker-socket-fix.sh
    command: /usr/local/bin/docker-socket-fix.sh
    networks:
      - ${var.project_name}-${var.environment}-network
    restart: unless-stopped
    user: "0:0"

volumes:
  jenkins_home:
    name: ${var.project_name}-jenkins-${var.environment}-home

networks:
  ${var.project_name}-${var.environment}-network:
    external: true
EOT
  
  filename = "${path.module}/jenkins-docker-compose.yml"
}

# Generate Docker socket fix script
resource "local_file" "docker_socket_fix" {
  content = file("${path.module}/docker-socket-fix.sh")
  
  filename = "${path.module}/docker-socket-fix.sh"
}