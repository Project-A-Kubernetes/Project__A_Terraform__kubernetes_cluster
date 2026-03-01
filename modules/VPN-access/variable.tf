variable "vpn-vpc-id" {
  type = string 
  description = "The vpc id for my vpn"
} 
variable "env" {
  type = string 
  description = "the infra environment"
}
variable "vpn-subents" {
  type = list(string)
  description = "private subnet in multi AZ in my vpc"
} 
variable "vpn-vpc-cidr" {
  type = string 
  description = "The vpc cidr block"
}
variable "client-cidr-block" {
  type = string 
  description = "The amount of ip that can be assign to connecting client like me and you"
}
variable "vpn-client" {
  type = list(string)
  description = "The users vpn certificate generation"
}
