
locals {
  cluster_name = "felix-aws-cluster"
}

module "VPC" {
  source           = "../../../modules/VPC"
  cidr             = "10.0.0.0/16"
  env              = "production"
  vpc-cluster-name = local.cluster_name
} 
