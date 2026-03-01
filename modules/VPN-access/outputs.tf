output "vpn-endpoint-id" {
  value = aws_ec2_client_vpn_endpoint.this.id
  description = "The vpn enpoint id"
} 
output "vpn-endpoint-arn" {
  value = aws_ec2_client_vpn_endpoint.this.arn
  description = "the enpoint arn "
}
output "vpn-sg" {
  value = aws_security_group.this.id 
  description = "This is the vpn sg that will be inputed into the control plane sg for access"
}