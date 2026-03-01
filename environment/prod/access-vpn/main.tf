locals {
  private-subnet = { for K, V in data.terraform_remote_state.network.outputs.private_subnet_id: K => V }

}
#production grade
module "VPN" {
  source             = "../../../modules/VPN-access"
  vpn-vpc-id         = data.terraform_remote_state.network.outputs.vpc_id
  vpn-subents        = values(local.private-subnet)
  vpn-vpc-cidr       = data.terraform_remote_state.network.outputs.vpc_cidr
  env                = "production"
  client-cidr-block  = "10.200.0.0/22"
  vpn-client = ["felix-john-devops"]
}