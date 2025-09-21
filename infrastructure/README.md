# Infrastructure as Code (IaC)

This directory contains all infrastructure definitions using Terraform following GitOps principles.

## 📁 Directory Structure

```
infrastructure/
├── environments/          # Environment-specific configurations
│   ├── dev/              # Development environment
│   ├── staging/          # Staging environment
│   └── prod/             # Production environment
├── modules/              # Reusable Terraform modules
│   ├── vpc/              # VPC and networking
│   ├── eks/              # Kubernetes cluster
│   ├── redis/            # Redis cache cluster
│   └── jenkins/          # Jenkins CI/CD
├── scripts/              # Deployment and utility scripts
└── README.md            # This file
```

## 🚀 Getting Started

### Prerequisites
- Terraform >= 1.0
- Docker installed
- kubectl installed (for cloud phase)
- AWS CLI configured (for cloud phase)

### Quick Start
1. Navigate to desired environment
2. Initialize Terraform
3. Plan and apply changes

```bash
cd infrastructure/environments/dev
terraform init
terraform plan
terraform apply
```

## 🌍 Environment Strategy

### Phase 1: Local Development (Days 1-2)
- **Purpose**: Learning and development
- **Infrastructure**: Docker Swarm local
- **Provider**: Docker provider for Terraform
- **Access**: All team members
- **Cost**: Free

### Phase 2: Cloud Deployment (Days 3-4)
- **Purpose**: Production-like demonstration
- **Infrastructure**: AWS/GCP managed services
- **Provider**: AWS/GCP provider for Terraform
- **Access**: DevOps team
- **Cost**: Free tier usage

### Development Environment
- **Purpose**: Development and testing
- **Resources**: Minimal resources for cost optimization
- **Access**: All team members
- **Updates**: Frequent updates for testing

### Staging Environment
- **Purpose**: Pre-production testing
- **Resources**: Production-like resources
- **Access**: DevOps team + Senior developers
- **Updates**: Weekly updates from dev

### Production Environment
- **Purpose**: Live production system
- **Resources**: Full production resources
- **Access**: DevOps team only
- **Updates**: Monthly updates from staging

## 🔧 Module Usage

### Docker Swarm Module (Phase 1)
```hcl
module "docker_swarm" {
  source = "../../modules/docker-swarm"
  
  environment = "dev"
  network_name = "microservices-network"
}
```

### Redis Module (Phase 1)
```hcl
module "redis" {
  source = "../../modules/redis"
  
  container_name = "microservices-redis-dev"
  image = "redis:7.0-alpine"
  ports = ["6379:6379"]
}
```

### VPC Module (Phase 2 - Cloud)
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  environment = "dev"
  cidr_block  = "10.0.0.0/16"
}
```

### EKS Module (Phase 2 - Cloud)
```hcl
module "eks" {
  source = "../../modules/eks"
  
  cluster_name = "microservices-dev"
  vpc_id       = module.vpc.vpc_id
}
```

## 📋 Deployment Process

### 1. Development
```bash
# Make changes in feature branch
git checkout -b feature/redis-cluster
# ... make changes ...
git commit -m "feat(infra): add Redis cluster"
git push origin feature/redis-cluster
```

### 2. Testing
```bash
# Deploy to dev environment
cd infrastructure/environments/dev
terraform plan
terraform apply
```

### 3. Promotion
```bash
# Merge to dev branch
# ... PR process ...
# Deploy to staging
cd infrastructure/environments/staging
terraform plan
terraform apply
```

### 4. Production
```bash
# Merge to staging branch
# ... PR process ...
# Deploy to production
cd infrastructure/environments/prod
terraform plan
terraform apply
```

## 🔒 Security Best Practices

### State Management
- Terraform state stored in S3
- State encryption enabled
- State locking with DynamoDB
- Access control via IAM

### Secrets Management
- No secrets in code
- Use AWS Secrets Manager
- Use Terraform variables
- Use environment variables

### Access Control
- Least privilege principle
- IAM roles for services
- Service accounts for pods
- Network policies for security

## 📊 Monitoring and Alerting

### Infrastructure Monitoring
- CloudWatch metrics
- Prometheus for Kubernetes
- Grafana dashboards
- AlertManager for alerts

### Cost Monitoring
- AWS Cost Explorer
- Terraform cost estimation
- Budget alerts
- Resource tagging

## 🚨 Troubleshooting

### Common Issues
1. **State conflicts**: Use terraform refresh
2. **Resource conflicts**: Check naming conventions
3. **Permission issues**: Verify IAM policies
4. **Network issues**: Check security groups

### Getting Help
- Check Terraform documentation
- Review AWS CloudFormation events
- Check Kubernetes events
- Contact DevOps team

## 📚 Documentation

- [GitOps Strategy](../docs/gitops-strategy.md)
- [Deployment Rules](../docs/deployment-rules.md)
- [Architecture Diagram](../docs/architecture.md)
- [Troubleshooting Guide](../docs/troubleshooting.md)

---

**Last Updated**: $(date)
**Version**: 1.0
**Owner**: DevOps Team
