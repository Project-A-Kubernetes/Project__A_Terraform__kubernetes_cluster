output "cluster-name" {
  description = "My cluster name"
  value       = aws_eks_cluster.cluster.name
}
output "workernode-name" {
  description = "my workernode name"
  value       = aws_eks_node_group.workernode.id
}
output "OIDC" {
  description = "my cluster oidc url"
  value       = aws_iam_openid_connect_provider.oidc.url
}
output "tls-certificate" {
  description = "my tls certificate from my cluster"
  value       = data.tls_certificate.tls.certificates

}
output "oidc_name" {
  description = "my cluster oidc arn"
  value       = aws_iam_openid_connect_provider.oidc.arn
}
output "workernode-sg" {
  description = "my  workernode security id"
  value       = aws_security_group.workernodesg.id
} 
output "cluster-endpoint" {
  value = aws_eks_cluster.cluster.endpoint
  description = "This is the cluster endpoint"
}
output "cluster-cert" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
  description = "The cluster certificate"
}