output "cmk-arn" {
  value       = aws_kms_alias.this.arn
  description = "This is the CMK arn to be use by my EKS cluster"
}
