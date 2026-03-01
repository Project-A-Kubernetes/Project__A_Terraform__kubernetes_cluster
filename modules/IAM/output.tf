output "cluster-role" {
  description = "The cluster role arn"
  value       = aws_iam_role.kube-cluster-role.arn
}
output "workernode-role" {
  description = "This output the worker node role arn"
  value       = aws_iam_role.workernode-role.arn
}
output "wokernode-policy-cni" {
  description = "The cni policy for my worker node"
  value       = aws_iam_role_policy_attachment.worker-cni.id
}
output "wokernode-policy-node" {
  description = "This is the wokernode policy"
  value       = aws_iam_role_policy_attachment.worker-policy.id
}
output "workernode-policy-ecr" {
  description = "This is the woker node ecr policy"
  value       = aws_iam_role_policy_attachment.worker-ecr.id
}

output "ebs-csi-role-arn" {
  description = "The csi role arn"
  value = aws_iam_role.ebs-csi.arn
}