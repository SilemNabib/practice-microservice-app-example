# ===========================================
# REDIS MODULE OUTPUTS
# ===========================================

output "redis_config_file" {
  description = "Path to generated Redis configuration file"
  value       = local_file.redis_config.filename
}

output "redis_docker_compose_file" {
  description = "Path to generated Redis Docker Compose file"
  value       = local_file.redis_docker_compose.filename
}

output "redis_configuration" {
  description = "Redis configuration summary"
  value = {
    port           = var.redis_port
    password_set   = var.redis_password != "" ? true : false
    cache_ttl_default = var.cache_ttl_default
    cache_ttl_todo_data = var.cache_ttl_todo_data
    cache_ttl_user_data = var.cache_ttl_user_data
  }
}

output "deployment_instructions" {
  description = "Instructions for deploying Redis"
  value = <<-EOT
    To deploy Redis with the generated configuration:
    
    1. Copy the generated files to your deployment directory:
       cp ${local_file.redis_config.filename} ./redis.conf
       cp ${local_file.redis_docker_compose.filename} ./redis-docker-compose.yml
    
    2. Deploy using Docker Compose:
       docker-compose -f redis-docker-compose.yml up -d
    
    3. Verify Redis is running:
       docker-compose -f redis-docker-compose.yml ps
       redis-cli -h localhost -p ${var.redis_port} -a ${var.redis_password} ping
  EOT
}