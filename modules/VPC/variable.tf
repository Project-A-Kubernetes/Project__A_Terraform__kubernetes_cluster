variable "cidr" {
  description = "The ip range for my vpc"
  type        = string
}
variable "env" {
  description = "The infrastructure environment"
  type        = string
}
variable "vpc-cluster-name" {
  description = "The cluster name"
  type = string
}