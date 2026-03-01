
output "cmk-RDS-id" {
  value       = aws_kms_alias.rds.arn
  description = "The encryption key for rds"
}