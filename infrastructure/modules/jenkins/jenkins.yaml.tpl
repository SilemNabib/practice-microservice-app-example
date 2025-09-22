# ===========================================
# JENKINS CONFIGURATION - SIMPLE AND ROBUST
# ===========================================

jenkins:
  systemMessage: "Jenkins for ${project_name} - ${environment} environment. Terraform v${terraform_version} ready."
  numExecutors: 2
  
  # Security configuration
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "${jenkins_admin_user}"
          password: "${jenkins_admin_password}"
  
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false

  # Global environment variables
  globalNodeProperties:
    - envVars:
        env:
          - key: "TERRAFORM_VERSION"
            value: "${terraform_version}"
          - key: "DOCKER_HOST"
            value: "unix:///var/run/docker.sock"
          - key: "JENKINS_URL"
            value: "${jenkins_url}"
