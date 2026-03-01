provider "kubernetes" {
  host  = data.terraform_remote_state.EKS.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.EKS.outputs.cluster_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "aws"
    args = [ "eks", "get-token", "--cluster-name", data.terraform_remote_state.EKS.outputs.cluster_name ]
  }
}

provider "helm" {
  kubernetes {
    host  = data.terraform_remote_state.EKS.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.EKS.outputs.cluster_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      args = [ "eks", "get-token", "--cluster-name", data.terraform_remote_state.EKS.outputs.cluster_name ]
    }
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.EKS.outputs.cluster_name
}