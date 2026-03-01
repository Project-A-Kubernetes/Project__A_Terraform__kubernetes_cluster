variable "db_name" {
  type        = string
  description = "The database name"
}
variable "engine" {
  type        = string
  description = "This define the type of the database engine"
}
variable "engine-version" {
  type        = string
  description = "The database engine version"
}
variable "instance-class" {
  type        = string
  description = "The type of db instance to define the type fo machine the db runs on"
}
variable "db-storage" {
  type        = number
  description = "The amount of desire storage"
}
variable "kms-key-id" {
  type        = string
  description = "The KMS key"
}
variable "cluster-name" {
  type        = string
  description = "The eks name"
}
variable "env" {
  type        = string
  description = "The infrastrucure environment"
}
variable "from-port" {
  type        = number
  description = "the from-port for db"
}
variable "to-port" {
  type        = number
  description = "the to-port for my db"
}
variable "workernode-sg" {
  type        = string
  description = "This is my workernode security group"
}
variable "db-subnets" {
  type        = list(string)
  description = "This is this subnets for my database, provide high availability as subnets will be in different AZ"
}
variable "db-username" {
  type        = string
  description = "This is the db username "
}
variable "rds-vpc-cidr" {
  type        = string
  description = "This is the vpc cird block"
}
variable "rds-sg-vpc-name" {
  type = string 
  description = "vpc id for my sg"
}