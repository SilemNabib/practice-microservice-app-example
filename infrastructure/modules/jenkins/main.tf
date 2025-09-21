# ===========================================
# JENKINS MODULE - CI/CD WITH TERRAFORM
# ===========================================

# ===========================================
# DOCKER IMAGE (Phase 1 - Local)
# ===========================================

# Pull Jenkins Docker image
resource "docker_image" "jenkins" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  name = "jenkins/jenkins:${var.jenkins_version}"
  
  keep_locally = true  # Keep image even if not used
}

# ===========================================
# DOCKER VOLUME (Phase 1 - Local)
# ===========================================

# Create volume for Jenkins data persistence
resource "docker_volume" "jenkins_data" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  name = "${var.project_name}-jenkins-${var.environment}-data"
}

# Create volume for Jenkins plugins
resource "docker_volume" "jenkins_plugins" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  name = "${var.project_name}-jenkins-${var.environment}-plugins"
}

# ===========================================
# JENKINS CONFIGURATION FILES
# ===========================================

# Jenkins configuration file
resource "local_file" "jenkins_config" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  filename = "${path.module}/jenkins.yaml"
  content = templatefile("${path.module}/jenkins.yaml.tpl", {
    project_name          = var.project_name
    environment          = var.environment
    jenkins_admin_user   = var.jenkins_admin_user
    jenkins_admin_password = var.jenkins_admin_password
    jenkins_url          = "http://localhost:${var.jenkins_port}"
    terraform_version    = var.terraform_version
  })
}

# Jenkins plugins file
resource "local_file" "jenkins_plugins" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  filename = "${path.module}/plugins.txt"
  content = templatefile("${path.module}/plugins.txt.tpl", {
    terraform_version = var.terraform_version
  })
}

# ===========================================
# DOCKER CONTAINER (Phase 1 - Local)
# ===========================================

# Create Jenkins container
resource "docker_container" "jenkins" {
  count = var.deployment_phase == "local" ? 1 : 0
  
  name  = "${var.project_name}-jenkins-${var.environment}"
  image = docker_image.jenkins[0].image_id
  
  # Container configuration
  restart = "unless-stopped"
  
  # Port mapping
  ports {
    internal = 8080
    external = var.jenkins_port
  }
  
  # Volume mounting for data persistence
  volumes {
    volume_name    = docker_volume.jenkins_data[0].name
    container_path = "/var/jenkins_home"
  }
  
  volumes {
    volume_name    = docker_volume.jenkins_plugins[0].name
    container_path = "/var/jenkins_home/plugins"
  }
  
  # Bind mount for configuration files
  volumes {
    host_path      = "${abspath(path.module)}/jenkins.yaml"
    container_path = "/var/jenkins_home/jenkins.yaml"
  }
  
  volumes {
    host_path      = "${abspath(path.module)}/plugins.txt"
    container_path = "/var/jenkins_home/plugins.txt"
  }
  
      # Mount Docker socket for Docker-in-Docker
      volumes {
        host_path      = replace(var.docker_host, "unix://", "")
        container_path = "/var/run/docker.sock"
        read_only      = false
      }
      
      # Use detected user for Docker socket access
      user = "${var.docker_socket_user}:${var.docker_socket_group}"
  
      # Environment variables
      env = [
        "JENKINS_OPTS=--httpPort=8080",
        "JAVA_OPTS=-Xmx2048m -Xms1024m",
        "JENKINS_ADMIN_USER=${var.jenkins_admin_user}",
        "JENKINS_ADMIN_PASSWORD=${var.jenkins_admin_password}",
        "JENKINS_URL=http://localhost:${var.jenkins_port}",
        "TERRAFORM_VERSION=${var.terraform_version}",
        "DOCKER_HOST=unix:///var/run/docker.sock",  # Always use mounted socket inside container
      ]
  
  # Health check
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:8080/login"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
  
  # Network configuration
  networks_advanced {
    name = var.network_name
  }
}

# ===========================================
# AWS ECS/EKS JENKINS (Phase 2 - Cloud) - COMMENTED OUT FOR TESTING
# ===========================================

# ECS Task Definition - COMMENTED OUT FOR TESTING
# resource "aws_ecs_task_definition" "jenkins" {
#   count = var.deployment_phase == "cloud" ? 1 : 0
#   
#   family                   = "${var.project_name}-jenkins-${var.environment}"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = var.jenkins_cpu
#   memory                   = var.jenkins_memory
#   execution_role_arn       = aws_iam_role.jenkins_execution[0].arn
#   task_role_arn           = aws_iam_role.jenkins_task[0].arn
#   
#   container_definitions = jsonencode([
#     {
#       name  = "jenkins"
#       image = "jenkins/jenkins:${var.jenkins_version}"
#       portMappings = [
#         {
#           containerPort = 8080
#           protocol      = "tcp"
#         }
#       ]
#       environment = [
#         {
#           name  = "JENKINS_ADMIN_USER"
#           value = var.jenkins_admin_user
#         },
#         {
#           name  = "JENKINS_ADMIN_PASSWORD"
#           value = var.jenkins_admin_password
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = aws_cloudwatch_log_group.jenkins[0].name
#           awslogs-region        = var.aws_region
#           awslogs-stream-prefix = "jenkins"
#         }
#       }
#     }
#   ])
#   
#   tags = var.tags
# }

# ===========================================
# MONITORING AND LOGGING
# ===========================================

# CloudWatch log group for Jenkins (cloud only) - COMMENTED OUT FOR TESTING
# resource "aws_cloudwatch_log_group" "jenkins" {
#   count = var.deployment_phase == "cloud" ? 1 : 0
#   
#   name              = "/aws/ecs/jenkins/${var.project_name}-${var.environment}"
#   retention_in_days = var.log_retention_days
#   
#   tags = var.tags
# }
