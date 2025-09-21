// ===========================================
// JENKINSFILE - CI/CD PIPELINE FOR MICROSERVICES
// ===========================================

// Define global environment variables
environment {
    DOCKER_REGISTRY = "your-docker-registry" // e.g., Docker Hub username or ECR URL
    AWS_REGION      = "us-west-2"
    AWS_ACCOUNT_ID  = "123456789012" // Replace with your AWS Account ID
    TERRAFORM_VERSION = "1.6.0"
}

// Define Docker agent for pipeline execution
// This agent will have Docker and Terraform installed
agent {
    docker {
        image 'jenkins/agent:latest'
        args '-v /var/run/docker.sock:/var/run/docker.sock -v /usr/local/bin/terraform:/usr/local/bin/terraform'
    }
}

// Define the pipeline stages
stages {
    // ===========================================
    // STAGE 1: CHECKOUT
    // ===========================================
    stage('Checkout') {
        steps {
            script {
                echo "Checking out SCM..."
                // Checkout the source code from Git
                git branch: 'dev', credentialsId: 'github-credentials', url: 'https://github.com/SilemNabib/practice-microservice-app-example.git'
            }
        }
    }

    // ===========================================
    // STAGE 2: BUILD MICROSERVICES
    // ===========================================
    stage('Build Microservices') {
        steps {
            script {
                echo "Building Docker images for microservices..."
                // Build Docker images for each microservice
                // Ensure docker-compose.yml is updated to use Terraform-managed Redis
                sh 'docker-compose build'
            }
        }
    }

    // ===========================================
    // STAGE 3: UNIT TESTS
    // ===========================================
    stage('Unit Tests') {
        steps {
            script {
                echo "Running unit tests for microservices..."
                // Example: Run unit tests for todos-api
                sh 'docker-compose run --rm todos-api npm test'
                // Add more unit tests for other microservices as needed
            }
        }
    }

    // ===========================================
    // STAGE 4: INFRASTRUCTURE PROVISIONING (TERRAFORM)
    // ===========================================
    stage('Terraform Plan') {
        steps {
            script {
                echo "Running Terraform plan for infrastructure..."
                dir('infrastructure/environments/dev') {
                    // Set environment variables for Terraform
                    withEnv([
                        "TF_VAR_docker_host=unix:///var/run/docker.sock",
                        "TF_VAR_redis_password=redis123",
                        "TF_VAR_jenkins_admin_user=admin",
                        "TF_VAR_jenkins_admin_password=admin123",
                        "TF_VAR_terraform_version=${env.TERRAFORM_VERSION}"
                    ]) {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }
    }

    stage('Terraform Apply') {
        steps {
            script {
                echo "Applying Terraform changes..."
                dir('infrastructure/environments/dev') {
                    withEnv([
                        "TF_VAR_docker_host=unix:///var/run/docker.sock",
                        "TF_VAR_redis_password=redis123",
                        "TF_VAR_jenkins_admin_user=admin",
                        "TF_VAR_jenkins_admin_password=admin123",
                        "TF_VAR_terraform_version=${env.TERRAFORM_VERSION}"
                    ]) {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }

    // ===========================================
    // STAGE 5: DEPLOY MICROSERVICES
    // ===========================================
    stage('Deploy Microservices') {
        steps {
            script {
                echo "Deploying microservices using Docker Compose..."
                // Copy .env.example to .env for Docker Compose
                sh 'cp docker-compose.env.example .env'
                // Start services, ensuring they connect to the Terraform-managed Redis
                sh 'docker-compose up -d auth-api users-api todos-api log-message-processor frontend'
            }
        }
    }

    // ===========================================
    // STAGE 6: INTEGRATION TESTS
    // ===========================================
    stage('Integration Tests') {
        steps {
            script {
                echo "Running integration tests..."
                // Example: Test Cache Aside pattern
                sh '''
                    # Authenticate and get JWT token
                    JWT_TOKEN=$(curl -s -X POST http://localhost:8083/login -H "Content-Type: application/json" -d '{"username": "admin", "password": "admin"}' | jq -r .accessToken)
                    
                    # First query (Cache MISS)
                    curl -s -X GET http://localhost:8082/todos -H "Authorization: Bearer $JWT_TOKEN"
                    
                    # Second query (Cache HIT)
                    curl -s -X GET http://localhost:8082/todos -H "Authorization: Bearer $JWT_TOKEN"
                    
                    # Create new TODO (Cache UPDATE)
                    curl -s -X POST http://localhost:8082/todos -H "Authorization: Bearer $JWT_TOKEN" -H "Content-Type: application/json" -d '{"content": "Test Cache Aside Pattern from Jenkins"}'
                    
                    # Verify updated list
                    curl -s -X GET http://localhost:8082/todos -H "Authorization: Bearer $JWT_TOKEN"
                '''
                echo "Integration tests passed!"
            }
        }
    }

    // ===========================================
    // STAGE 7: CLEANUP
    // ===========================================
    stage('Cleanup') {
        steps {
            script {
                echo "Cleaning up Docker Compose services..."
                sh 'docker-compose down'
                echo "Cleanup complete."
            }
        }
    }
}

// Define post-build actions
post {
    always {
        echo "Pipeline finished."
    }
    success {
        echo "Pipeline successful!"
    }
    failure {
        echo "Pipeline failed!"
    }
}