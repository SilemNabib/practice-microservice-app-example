# GitOps Strategy for Microservices Infrastructure

## 🎯 Overview

This document defines the GitOps branching strategy for infrastructure and operations, following the principle of **Git as the single source of truth** for infrastructure.

## 🌳 Branching Strategy

### Branch Structure

```
main (production)
  ↑
staging (staging environment)
  ↑
dev (development environment)
  ↑
feature/* (infrastructure features)
```

### Branch Definitions

#### `main` Branch
- **Purpose**: Production infrastructure
- **Protection**: Only accepts merges from `staging`
- **Deployment**: Automatic deployment to production
- **Access**: DevOps team only

#### `staging` Branch
- **Purpose**: Staging environment testing
- **Protection**: Only accepts merges from `dev`
- **Deployment**: Automatic deployment to staging
- **Access**: DevOps team + Senior developers

#### `dev` Branch
- **Purpose**: Development environment
- **Protection**: Only accepts merges from `feature/*`
- **Deployment**: Automatic deployment to dev
- **Access**: All team members

#### `feature/*` Branches
- **Purpose**: Infrastructure features and experiments
- **Naming**: `feature/description` (e.g., `feature/redis-cluster`, `feature/eks-setup`)
- **Lifecycle**: Created from `dev`, merged back to `dev`
- **Access**: All team members

## 🔄 Workflow Process

### 1. Feature Development
```bash
# Create feature branch from dev
git checkout dev
git pull origin dev
git checkout -b feature/redis-cluster

# Work on infrastructure changes
# ... make changes ...

# Commit changes
git add .
git commit -m "feat(infra): add Redis cluster configuration"

# Push and create PR
git push origin feature/redis-cluster
```

### 2. Promotion Process
```bash
# Feature → Dev (automatic after PR approval)
# Dev → Staging (manual promotion after testing)
# Staging → Main (manual promotion after staging validation)
```

### 3. Emergency Hotfixes
```bash
# Create hotfix from main
git checkout main
git checkout -b hotfix/critical-security-patch

# Make emergency changes
# ... emergency fixes ...

# Merge to main and staging simultaneously
git checkout main
git merge hotfix/critical-security-patch
git checkout staging
git merge hotfix/critical-security-patch
```

## 📁 Directory Structure

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── redis/
│   └── jenkins/
└── scripts/
    ├── deploy.sh
    ├── rollback.sh
    └── validate.sh
```

## 🔒 Security Rules

### Branch Protection
- **main**: Requires 2 approvals, no direct pushes
- **staging**: Requires 1 approval, no direct pushes
- **dev**: Allows direct pushes from team members

### Access Control
- **Infrastructure changes**: DevOps team only
- **Configuration changes**: DevOps + Senior developers
- **Documentation**: All team members

## 🚀 Deployment Triggers

### Automatic Deployments
- **Push to dev** → Deploy to dev environment
- **Push to staging** → Deploy to staging environment
- **Push to main** → Deploy to production environment

### Manual Deployments
- **Emergency deployments**: Manual trigger with approval
- **Rollbacks**: Manual trigger with justification

## 📋 Commit Message Convention

```
type(scope): description

Types:
- feat(infra): new infrastructure feature
- fix(infra): infrastructure bug fix
- docs(infra): infrastructure documentation
- refactor(infra): infrastructure refactoring
- test(infra): infrastructure testing

Examples:
- feat(redis): add Redis cluster with high availability
- fix(eks): resolve node group scaling issue
- docs(terraform): update deployment documentation
```

## 🔍 Review Process

### Pull Request Requirements
1. **Description**: Clear explanation of changes
2. **Testing**: Evidence of testing in dev environment
3. **Documentation**: Updated documentation if needed
4. **Rollback Plan**: Clear rollback strategy
5. **Impact Assessment**: Description of potential impacts

### Approval Process
1. **Self-review**: Author reviews their own changes
2. **Peer review**: Another DevOps engineer reviews
3. **Testing validation**: Automated tests must pass
4. **Documentation check**: Documentation must be updated

## 📊 Monitoring and Alerting

### Deployment Monitoring
- **Success/failure notifications**: Slack/email alerts
- **Deployment duration**: Track deployment times
- **Rollback triggers**: Automatic rollback on failure

### Infrastructure Health
- **Resource utilization**: Monitor CPU, memory, disk
- **Service availability**: Monitor service uptime
- **Cost tracking**: Monitor infrastructure costs

## 🎯 Success Metrics

- **Deployment frequency**: Target daily deployments
- **Lead time**: Target < 1 hour from commit to production
- **Mean time to recovery**: Target < 30 minutes
- **Change failure rate**: Target < 5%

---

**Last Updated**: $(date)
**Version**: 1.0
**Owner**: DevOps Team
