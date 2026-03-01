terraform {
  #my remote state backend for my network
  backend "s3" {
    bucket         = "project-a-kubernetes-state"
    dynamodb_table = "project-a-kubernetes-state-locking"
    key            = "prod/network/terraform-state.tfstate"
    encrypt        = true
    region         = "us-east-1"
  }
}