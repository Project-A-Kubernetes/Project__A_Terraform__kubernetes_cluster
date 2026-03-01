#this local cluster name will be properly configured later
locals {
  cluster_name = "felix-aws-cluster"
}
#this is my vp module, the foundation for everything that is running privately and publicly now
module "VPC" {
  source           = "../../../modules/VPC"
  cidr             = "10.0.0.0/16"
  env              = "production"
  vpc-cluster-name = local.cluster_name
} #new