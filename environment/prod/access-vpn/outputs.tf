output "vpn_endpoint-id" {
  value = module.VPN.vpn-endpoint-id
  description = "The vpn enpoint id"
} 
output "vpn_endpoint-arn" {
  value = module.VPN.vpn-endpoint-arn
  description = "the enpoint arn "
}
output "vpn_sg" {
  value = module.VPN.vpn-sg
  description = "This is the vpn sg that will be inputed into the control plane sg for access"
}