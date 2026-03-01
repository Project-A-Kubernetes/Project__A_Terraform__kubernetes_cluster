locals {
  private-subnet = { for K, V in data.terraform_remote_state.network.outputs.private_subnet_id: K => V }

}

module "EKS" {
  source                       = "../../../modules/EKS"
  workernode-role              = module.IAM.workernode-role
  workernode-subnet            = values(local.private-subnet)
  cluster-name                 = "felix-aws-cluster"
  cluster-role                 = module.IAM.cluster-role
  cluster-subnet               = values(local.private-subnet)
  env                          = "production"
  cluster-version              = "1.34"
  wokernode-policy-cni         = module.IAM.wokernode-policy-cni
  wokernode-policy-node-policy = module.IAM.wokernode-policy-node
  wokernode-policy-ecr         = module.IAM.workernode-policy-ecr
  workernode-name              = "Felix-workernode"
  cmk-key                      = module.encryption.cmk-arn
  sg-vpc                       = data.terraform_remote_state.network.outputs.vpc_id
  ebs-csi-role = module.IAM.ebs-csi-role-arn
  worker-cidr-blocks = data.terraform_remote_state.network.outputs.vpc_cidr
  vpn-sg =  data.terraform_remote_state.access-vpn.outputs.vpn_sg 
} 
module "encryption" {
  source = "../../../modules/encryption-secrets/eksencrypt"  
  env = "production"
} 

module "IAM" {
  source          = "../../../modules/IAM"
  role-name       = "kube-cluster-role"
  env             = "production"
  workernode-role = "kubernetes-wokernode"
  oidc-ident-arn  = module.EKS.oidc_name
  oidc-role       = "kube-SA-OIDC"
  oidc-url        = module.EKS.OIDC
}