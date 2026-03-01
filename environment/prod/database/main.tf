locals {
  private-subnet = { for K, V in data.terraform_remote_state.network.outputs.private_subnet_id: K => V }
}
module "RDS" {
  source          = "../../../modules/RDS"
  db-username     = "Felix"
  db-subnets      = values(local.private-subnet)
  workernode-sg   = data.terraform_remote_state.EKS.outputs.workernode_sg
  to-port         = 3306
  from-port       = 3306
  engine          = "mysql"
  engine-version  = "8.4.7"
  env             = "production"
  cluster-name    = data.terraform_remote_state.EKS.outputs.cluster_name
  kms-key-id      = module.encryption.cmk-RDS-id
  instance-class  = "db.t4g.micro"
  db-storage      = 50
  db_name         = "projectakubernetes"
  rds-vpc-cidr    = data.terraform_remote_state.network.outputs.vpc_cidr
  rds-sg-vpc-name = data.terraform_remote_state.network.outputs.vpc_id
} 
module "encryption" {
  source = "../../../modules/encryption-secrets/rdsencrypt" 
  env = "production"
}