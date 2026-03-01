# we will be using this outputn through out the infrastruture
output "vpc_id" {
  description = "This print out the vpc id"
  value       = aws_vpc.kube-net.id
}
output "public_subnet_id" {
  description = "This output the public subnet id"
  value       = { for K, V in aws_subnet.public_subnet : K => V.id }
}
output "private_subnet_id" {
  description = "This print out the private subnet id"
  value       = { for K, V in aws_subnet.private_subnet : K => V.id }
}
output "vpc-cidr" {
  value       = aws_vpc.kube-net.cidr_block
  description = "This vpc cidr block"
}