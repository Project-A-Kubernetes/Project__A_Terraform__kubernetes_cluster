#creating a custom managed encryption  key for my cluster, this key encryption my EKS secret stored in etcd at rest
resource "aws_kms_key" "this" {
  description             = "My encryption key"
  rotation_period_in_days = 90
  enable_key_rotation     = true
  tags = {
    environemnt = var.env
    Name        = "project-a-encryption-key"
  }
}
resource "aws_kms_alias" "this" {
  name          = "alias/encrypt-key"
  target_key_id = aws_kms_key.this.id
  #next attach kms to eks in eks modules
}

