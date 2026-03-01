#installing argocd so the cluster is gitops ready 
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = ""
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.16"



}