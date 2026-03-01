#=============
# CMK for RDS 
#============== 
resource "aws_kms_key" "rds" {
  description             = "KMS key for my RDS "
  enable_key_rotation     = true
  rotation_period_in_days = 90
  tags = {
    environemnt = var.env
    Name        = "project-a-rds-encryption-key"
  }
}
resource "aws_kms_alias" "rds" {
  name          = "alias/rds-encryption"
  target_key_id = aws_kms_key.rds.id
}