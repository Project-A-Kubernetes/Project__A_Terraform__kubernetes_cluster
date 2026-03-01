from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform
from diagrams.aws.network import VPC, InternetGateway, PublicSubnet, PrivateSubnet, NATGateway
from diagrams.aws.database import RDS
from diagrams.onprem.compute import Server
from diagrams.onprem.gitops import ArgoCD
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.client import User
from diagrams.aws.compute import EC2

with Diagram("Project-A Terraform Provisioned Infra", show=False, direction="TB"):

    # Terraform IaC
    terraform = Terraform("Terraform\n(IaC)")

    # External actors
    dev = User("DEVOPS-ENGINEER")
    engineer = User("Engineers")

    # VPC / Network Layer
    with Cluster("VPC"):
        igw = InternetGateway("Internet Gateway")

        # Public Subnets
        with Cluster("Public Subnets"):
            public_subnet1 = PublicSubnet("Public Subnet 1")
            public_subnet2 = PublicSubnet("Public Subnet 2")
            public_subnet3 = PublicSubnet("Public Subnet 3")

        # Private Subnets
        with Cluster("Private Subnets"):
            private_subnet1 = PrivateSubnet("Private Subnet 1")
            private_subnet2 = PrivateSubnet("Private Subnet 2")
            private_subnet3 = PrivateSubnet("Private Subnet 3")

        # NAT Gateway for private subnets
        nat = NATGateway("NAT Gateway")

        # Connections within VPC
        igw >> public_subnet1
        igw >> public_subnet2
        igw >> public_subnet3
        private_subnet1 >> nat
        private_subnet2 >> nat
        private_subnet3 >> nat

    # VPN Server for secure access
    vpn = EC2("VPN Server / Access")
    engineer >> vpn >> private_subnet1
    engineer >> vpn >> private_subnet2

    # Kubernetes Cluster (EKS)
    eks = Server("EKS Cluster")
    eks << private_subnet1
    eks << private_subnet2
    eks << private_subnet3

    # Database
    db = RDS("Database (RDS)")
    db << private_subnet1
    db << private_subnet2
    db << private_subnet3

    # GitOps / ArgoCD
    argocd = ArgoCD("ArgoCD (GitOps)")

    # Monitoring
    with Cluster("Monitoring"):
        prometheus = Prometheus("Prometheus")
        grafana = Grafana("Grafana")
        prometheus >> grafana

    # Remote state backend
    remote_state = Terraform("Remote State Backend\n(S3 + DynamoDB)")

    # Connections
    dev >> terraform
    terraform >> [igw, nat, vpn, eks, db, argocd, prometheus, grafana, remote_state]