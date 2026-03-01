output "remote-bucket-name" {
  description = "This output the remote-state bucket name so other resources can consume it"
  value       = aws_s3_bucket.state-bucket.bucket
}
output "remote-state-locking" {
  description = "This output the dynamodb name that enables remote state lcoking"
  value       = aws_dynamodb_table.state-locking-dynamodb.name
}