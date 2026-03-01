#installing argocd so the cluster is gitops ready 
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.16"


  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}