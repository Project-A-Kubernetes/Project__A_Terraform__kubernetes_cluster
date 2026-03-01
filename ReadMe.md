# PROJECT-A-EKS-TERRAFORM

## 📌 Overview

This repository contains a modular, production-ready Infrastructure as Code (IaC) implementation for provisioning a secure and scalable Amazon EKS Kubernetes cluster on AWS using Terraform. 


## architecture diagram
![Architecture Diagram](diagram/infra.png)


### The architecture is designed with:

- Environment isolation (e.g., prod, staging)
- Modular Terraform structure
- Remote state management
- IAM least-privilege principles
- OIDC integration for Kubernetes service accounts
- CI/CD integration readiness
- Production networking standards 
- AWS RDS as database 
- VPN for secure cluster access from engineers to EKS


## 🏗 Architecture Design
Core Infrastructure Components

- Custom VPC with public and private subnets
- NAT Gateway for private subnet egress
- Internet Gateway
- Route tables per subnet tier (HA)
- Security groups with strict ingress/egress rules
- EKS Control Plane
- Managed Node Groups
- IAM roles for:
    - EKS cluster
    - Worker nodes
    - EKS add-ons
    - IRSA (OIDC-based service account roles)
- OIDC provider integration
- ECR integration (for container workloads)
- Optional: EBS CSI driver IAM role configuration


## 📂 Repository Structure
Project_A_Terraform/
│
├── README.md
├── environment/                # Environment-specific infrastructure
│   ├── dev/                    # Development environment
│   │
│   ├── staging/                # Staging environment
│   │
│   │
│   └── prod/                   # Production environment
│       ├── network/            # VPC, subnets, IGWs, NAT
│       ├── access-vpn/         # VPN access modules/config
│       ├── database/           # RDS / database infra
│       ├── EKS/                # Kubernetes cluster
│       ├── platform/           # Addons like ArgoCD,             
│
├── modules/                    # Reusable Terraform modules
│   ├── VPC/
│   ├── VPN-access/
│   ├── EKS/
│   ├── RDS/
│   ├── IAM/
│   ├── Argocd/
│   └── encryption-secrets/
│
└── remote-state/               # Remote state backend configs (S3/DynamoDB)

