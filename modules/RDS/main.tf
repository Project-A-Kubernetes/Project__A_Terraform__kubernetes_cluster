#Relational database 
resource "aws_db_instance" "this" {
  identifier                 = var.db_name
  instance_class             = var.instance-class
  engine                     = var.engine
  engine_version             = var.engine-version
  allocated_storage          = var.db-storage
  max_allocated_storage      = 100
  storage_type               = "gp3"
  storage_encrypted          = true
  kms_key_id                 = var.kms-key-id
  multi_az                   = true
  publicly_accessible        = false
  skip_final_snapshot        = true
 # backup_retention_period    = 3  for permanent db this can be enable
  delete_automated_backups   = true 
  backup_window              = "03:00-04:00" 
  maintenance_window         = "sun:05:00-sun:06:00"
  auto_minor_version_upgrade = true
  deletion_protection        = false #use true for your permanent workload
  vpc_security_group_ids     = [aws_security_group.rds-sg.id]
  db_subnet_group_name       = aws_db_subnet_group.this.name

  #manage database username and password 
  username                    = var.db-username
  manage_master_user_password = true

  lifecycle {
    ignore_changes = [kms_key_id]
  }

  tags = {
    Name        = "${var.cluster-name}-database"
    environemnt = var.env
  }
}
#database subnets 
resource "aws_db_subnet_group" "this" {
    
  name       = "${var.cluster-name}-db-subnets"
  subnet_ids = var.db-subnets 
  tags = {
    Name        = "${var.cluster-name}-subnetgroup"
    environemnt = var.env
  }
}
#rds security group 
resource "aws_security_group" "rds-sg" {
    vpc_id = var.rds-sg-vpc-name
  ingress {
    description     = "Allow inbound from workernode only"
    from_port       = var.from-port
    to_port         = var.to-port
    protocol        = "tcp"
    security_groups = [var.workernode-sg]
  }
  egress {
    description = "Allow traffic from anywhere in the vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.rds-vpc-cidr]
  }
  tags = {
    Name        = "${var.cluster-name}-sg"
    environemnt = var.env
  }
}