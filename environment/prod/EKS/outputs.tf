output "cluster_name" {
  description = "My cluster name"
  value       = module.EKS.cluster-name
}
output "workernode_name" {
  description = "my workernode name"
  value       = module.EKS.workernode-name
}
output "OIDC" {
  description = "my cluster oidc url"
  value       = module.EKS.OIDC
}
output "tls_certificate" {
  description = "my tls certificate from my cluster"
  value       = module.EKS.tls-certificate

}
output "oidc_name" {
  description = "my cluster oidc arn"
  value       = module.EKS.oidc_name
}
output "workernode_sg" {
  description = "my  workernode security id"
  value       = module.EKS.workernode-sg
} 
output "cluster_endpoint" {
  value = module.EKS.cluster-endpoint
  description = "This is the cluster endpoint"
}
output "cluster_cert" {
  value = module.EKS.cluster-cert
  description = "The cluster certificate"
}