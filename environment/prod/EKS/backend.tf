data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "project-a-kubernetes-state"
    key    = "prod/network/terraform-state.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
data "terraform_remote_state" "access-vpn" {
  backend = "s3"
  config = {
    bucket = "project-a-kubernetes-state"
    key = "prod/vpn-access/terraform-state.tfstate"
    region = "us-east-1"
    encrypt = true 
  }
}
terraform {
  backend "s3" {
     bucket = "project-a-kubernetes-state" 
     key = "prod/EKS/terraform-state.tfstate"
     dynamodb_table = "project-a-kubernetes-state-locking"
     encrypt = true 
     region = "us-east-1"
  }
}