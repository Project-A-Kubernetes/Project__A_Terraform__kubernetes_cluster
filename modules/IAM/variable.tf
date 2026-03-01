variable "role-name" {
  description = "this is the name of the kubernetes cluster role"
  type        = string

}
variable "workernode-role" {
  description = "The name of my worker node"
  type        = string
}
variable "env" {
  description = "The environment where the cluster is design to be deployed"
  type        = string
}
variable "oidc-role" {
  description = "The name of the service account role"
  type        = string
}
variable "oidc-ident-arn" {
  description = "the oidc arn"
  type        = string
}
variable "oidc-url" {
  type        = string
  description = "The url for my condition in defining the oidc policy"
}