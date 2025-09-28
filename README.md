# Team Members
- A00395548 | Silem Nabib Villa Contreras
- A00382203 | Santiago Escobar Leon

# Table of Contents
- [Introduction](#introduction)
- [Branching Strategies](#branching-strategies)
- [Selected Cloud Patterns](#selected-cloud-patterns)
- [Architecture Diagram](#architecture-diagram)
- [Development Pipelines](#development-pipelines)
- [Infrastructure Pipelines](#infrastructure-pipelines)
- [Infrastructure Implementation](#infrastructure-implementation)
- [Demonstration](#demonstration)
- [Conclusions](#conclusions)

# Introduction
>TODO: Add introduction

# Branching Strategies

For this project, we have implemented the GitFlow branching strategy, which provides a robust framework for managing both development and operations workflows.

## Development Branching Strategy

Our development branching strategy follows the GitFlow model with the following branches:

- **main**: Production-ready code that has been thoroughly tested and is ready for deployment
- **develop**: Integration branch for features being developed
- **feature/\***: Individual feature branches created from and merged back into develop
- **hotfix/\***: Emergency fixes for production issues, branched from main and merged into both main and develop
- **release/\***: Preparation branches for releases, branched from develop and merged into main and develop

This strategy allows developers to work on features in isolation while maintaining a stable codebase.

## Operations Branching Strategy

For operations, we extend the GitFlow model with environment-specific branches:

- **env/dev**: Configuration specific to the development environment
- **env/prod**: Configuration specific to the production environment
- **infra/\***: Infrastructure changes that are tested in each environment sequentially

This approach ensures that infrastructure changes follow a controlled promotion path from development to production, reducing the risk of configuration drift and deployment issues.

# Selected Cloud Patterns
>TODO: Add selected cloud patterns

# Architecture Diagram

The architecture for our microservices application is designed to leverage Google Cloud Platform services for optimal performance, scalability, and reliability. The diagram below illustrates the high-level architecture and the interactions between different components.

## Overview

Our architecture consists of the following key components:

- Frontend (Vue.js) deployed on Cloud Run
- Auth API (Go) deployed on Cloud Run
- TODOs API (Node.js) deployed on Cloud Run
- Users API (Java Spring Boot) deployed on GKE
- Log Message Processor (Python) deployed on Cloud Run
- Redis for message queue and caching
- Cloud SQL for persistent data storage

## Cloud Patterns

We will implement the following cloud design patterns:

### Cache-Aside Pattern

>TODO: Extend this section with implementation details of the Cache-Aside pattern using Cloud Memorystore (Redis) to improve performance by reducing database load and latency for frequently accessed data.

### Circuit Breaker Pattern

>TODO: Extend this section with implementation details of the Circuit Breaker pattern to improve system resilience by preventing cascading failures when a service is unavailable or experiencing high latency.

## Diagram

>TODO: Insert architecture diagram image showing the components and their interactions, including the implementation of the selected cloud patterns.

# Development Pipelines
>TODO: Add development pipelines

# Infrastructure Pipelines
>TODO: Add infrastructure pipelines

# Infrastructure Implementation
>TODO: Add infrastructure implementation

# Demonstration
>TODO: Add demonstration

# Conclusions
>TODO: Add conclusions
