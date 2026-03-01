variable "provider-region" {
  description = "This cloud region where the infrastruture will be deployed to"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The kind of environment the resources will be in"
  type        = string
  default     = "production"
}