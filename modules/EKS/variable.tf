variable "cluster-name" {
  description = "This define the cluster name"
  type        = string
}
variable "cluster-version" {
  description = "The version of the cluster we want to deploy"
  type        = string
}
variable "cluster-role" {
  description = "The cluster role"
  type        = string
}
variable "cluster-subnet" {
  description = "The subnet where the cluster we be built on"
  type        = list(string)
}
variable "env" {
  description = "This distributing environment"
  type        = string
}

variable "workernode-name" {
  description = "This define the worker node group name"
  type        = string
}
variable "workernode-subnet" {
  description = "the define the subnet"
  type        = list(string)
}
variable "workernode-role" {
  description = "The worker node group role"
  type        = string
}

variable "wokernode-policy-cni" {
  description = "The cni policy for my workernode"
  type        = string
}
variable "wokernode-policy-ecr" {
  description = "The ecr policy for my workernode"
  type        = string
}
variable "wokernode-policy-node-policy" {
  description = "The node policy for my workernode"
  type        = string
}
variable "cmk-key" {
  type        = string
  description = "KMS key for etcd encryption at rest"
}
variable "sg-vpc" {
  type        = string
  description = "The vpc for my sg"
}
variable "worker-cidr-blocks" {
  type = string 
  description = "This is the cidr block for my workernode and it will be the vpc cidr"
} 
variable "ebs-csi-role" {
  type = string 
  description = "The csin driver role"
}
variable "vpn-sg" {
  type = string 
  description = "This is where the vpn sg id come into our controll plane sg for private and secure access"
}