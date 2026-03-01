
# we will be using this outputn through out the infrastruture
output "vpc_id" {
  description = "This print out the vpc id for the environment"
  value       = module.VPC.vpc_id
}
output "public_subnet_id" {
  description = "This output the public subnet id for the environment"
  value       = module.VPC.public_subnet_id
}
output "private_subnet_id" {
  description = "This print out the private subnet id for the env"
  value       = module.VPC.private_subnet_id
}
output "vpc_cidr" {
  value       = module.VPC.vpc-cidr
  description = "This vpc cidr block"
}
