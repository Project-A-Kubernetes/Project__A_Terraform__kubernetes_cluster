locals {
  bucketName   = "project-a-kubernetes-state"
  dynamodbName = "project-a-kubernetes-state-locking"
}

# creating the remote state s3 bucket 
resource "aws_s3_bucket" "state-bucket" {
  bucket = local.bucketName
  lifecycle {
    prevent_destroy = true #we do this so the bucket is not mistakely deleted 
  }
  tags = {
    environemnt = var.env
  }
}

#enable bucket versioning: because this is a remote state bucket and changes is constant so we want the bucket to have to ability to chnange state 
resource "aws_s3_bucket_versioning" "state-bucket-versioning" {
  bucket = aws_s3_bucket.state-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#enable bucket server side encryption....since this is a very import bucket for our infrastructure it is best we enable bucket encryption with KMS or s3 built in encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "state-bucket-encryption" {
  bucket = aws_s3_bucket.state-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#This ensures that when one engineer or CI pipeline is running terraform apply, a lock is placed on the state file. Any other execution attempt will fail immediately instead of causing state conflicts or corruption.
resource "aws_dynamodb_table" "state-locking-dynamodb" {
  name         = local.dynamodbName
  hash_key     = "LockID"          #this enable state locking 
  billing_mode = "PAY_PER_REQUEST" # this describe the billing mode.. so we pay per any request 
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "state-locking"
    environemnt = var.env
  }

}