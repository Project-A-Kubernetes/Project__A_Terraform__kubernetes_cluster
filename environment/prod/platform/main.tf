
module "argo" {
  source = "../../../modules/Argocd"
}

module "observability" {
  source = "../../../modules/observability"
}