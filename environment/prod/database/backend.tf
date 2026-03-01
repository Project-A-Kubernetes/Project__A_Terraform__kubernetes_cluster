data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "project-a-kubernetes-state"
    key    = "prod/network/terraform-state.tfstate"
    region = "us-east-1"
    encrypt = true
  }
} 
data "terraform_remote_state" "EKS" {
  backend = "s3"
  config = {
    bucket = "project-a-kubernetes-state"
    key = "prod/EKS/terraform-state.tfstate"
    encrypt = true 
    region = "us-east-1"
  }
}
terraform {
  backend "s3" {
    bucket = "project-a-kubernetes-state"
    key = "prod/Database/terraform-state.tfstate"
    encrypt = true 
    region = "us-east-1"
    dynamodb_table = "project-a-kubernetes-state-locking"
  }
}