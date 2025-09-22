# Microservice App - PRFT Devops Training

This is the application you are going to use through the whole training. This, hopefully, will teach you the fundamentals you need in a real project. You will find a basic TODO application designed with a [microservice architecture](https://microservices.io). Although is a TODO application, it is interesting because the microservices that compose it are written in different programming language or frameworks (Go, Python, Vue, Java, and NodeJS). With this design you will experiment with multiple build tools and environments.

## 🚀 DevOps Implementation Status

### ✅ **COMPLETED IMPLEMENTATIONS:**

1. **Infrastructure as Code (Terraform)** ✅
   - Redis infrastructure with Terraform
   - Hybrid local/cloud approach
   - Environment variable configuration
   - Docker network management

2. **Cache Aside Pattern** ✅
   - Implemented in todos-api (Node.js)
   - Redis v4 integration with async/await
   - Configurable TTL for different data types
   - Comprehensive error handling and logging
   - **FULLY TESTED AND WORKING**

3. **GitOps Branching Strategy** ✅
   - Operations branching strategy implemented
   - Documentation for deployment procedures

### 🔄 **IN PROGRESS:**
- Jenkins CI/CD setup with Terraform integration
- Circuit Breaker pattern implementation

### 📋 **PENDING:**
- Development pipelines (build, test, deploy)
- Infrastructure pipelines with Terraform
- Testing automation and end-to-end testing
- Architecture diagram with Terraform components 

## Components
In each folder you can find a more in-depth explanation of each component:

1. [Users API](/users-api) is a Spring Boot application. Provides user profiles. At the moment, does not provide full CRUD, just getting a single user and all users.
2. [Auth API](/auth-api) is a Go application, and provides authorization functionality. Generates [JWT](https://jwt.io/) tokens to be used with other APIs.
3. [TODOs API](/todos-api) is a NodeJS application, provides CRUD functionality over user's TODO records. Also, it logs "create" and "delete" operations to [Redis](https://redis.io/) queue.
4. [Log Message Processor](/log-message-processor) is a queue processor written in Python. Its purpose is to read messages from a Redis queue and print them to standard output.
5. [Frontend](/frontend) Vue application, provides UI.

## 📚 Documentation

### DevOps Implementation Guides:
- **[TERRAFORM-GUIDE.md](./TERRAFORM-GUIDE.md)** - Complete guide for Terraform infrastructure setup
- **[CACHE-ASIDE-IMPLEMENTATION.md](./CACHE-ASIDE-IMPLEMENTATION.md)** - Cache Aside pattern implementation and testing results
- **[docs/gitops-strategy.md](./docs/gitops-strategy.md)** - GitOps branching strategy documentation
- **[docs/deployment-rules.md](./docs/deployment-rules.md)** - Deployment rules and procedures

### Quick Start:
1. **Setup Infrastructure**: Follow [TERRAFORM-GUIDE.md](./TERRAFORM-GUIDE.md)
2. **Configure Environment**: Copy `docker-compose.env.example` to `.env`
3. **Start Services**: `docker-compose up -d`
4. **Test Cache Aside**: Follow [CACHE-ASIDE-IMPLEMENTATION.md](./CACHE-ASIDE-IMPLEMENTATION.md)

## Architecture

Take a look at the components diagram that describes them and their interactions.
![microservice-app-example](/arch-img/Microservices.png)

### Enhanced Architecture (with DevOps implementations):
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │    │   todos-api      │    │   Redis Cache   │
│   (Vue.js)      │◄──►│   (Node.js)      │◄──►│   (Terraform)   │
│   Port: 3000    │    │   Port: 8082     │    │   Port: 6379    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   Auth API       │    │   Users API     │
                       │   (Go)           │◄──►│   (Java/Spring) │
                       │   Port: 8083     │    │   Port: 8081    │
                       └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   Log Processor  │    │   Zipkin        │
                       │   (Python)       │◄──►│   (Tracing)     │
                       │   Port: 8084     │    │   Port: 9411    │
                       └──────────────────┘    └─────────────────┘
```