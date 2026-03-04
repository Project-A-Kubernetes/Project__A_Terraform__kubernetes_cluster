
data "terraform_remote_state" "EKS" {
  backend = "s3"
  config = {
    bucket = "felix-terraform-kubernetes-state"
    key = "prod/EKS/terraform-state.tfstate"
    encrypt = true 
    region = "us-east-1"
  }
}

terraform {
  backend "s3" {
     bucket = "felix-terraform-kubernetes-state" 
     key = "prod/Platform/terraform-state.tfstate"
     dynamodb_table = "project-a-kubernetes-state-locking"
     encrypt = true 
     region = "us-east-1"
  }

}