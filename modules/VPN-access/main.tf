#creating security group for vpn 
resource "aws_security_group" "this" {
  vpc_id = var.vpn-vpc-id 
#because any traffic from vpn to vpc is already authenticated using the mutual Tls so we allow all traffic and protocol
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "Allow all verified secure access from vpn endpoint"
    cidr_blocks = [ var.client-cidr-block ] # restrict it to only the vpn client cidr block, so only assigned ip can access
  }
  egress {
    from_port = 443 
    to_port = 443 
    protocol = "tcp"
    description = "this allow a secure connect from the vpn ENI to the api server endpoint or other resources in a secure channel"
    cidr_blocks =  [ var.vpn-vpc-cidr ]
  }
} 

#configuring cloudwatch to fetch vpn logs 
resource "aws_cloudwatch_log_group" "this" {
  name = "prod/vpn-logs"
  retention_in_days = 7 #increament to desire 
  tags = {
    environemnt = var.env 
    Name = "${var.env}_vpn-logs"
  }
}

#creating the vpn endpoint
resource "aws_ec2_client_vpn_endpoint" "this" {
  description = "this is the vpn endpoint cient will connect to be able to access my api server"
  security_group_ids = [ aws_security_group.this.id ]
  split_tunnel = true #allows only traffic meant for vpc resources access only from client
  server_certificate_arn = aws_acm_certificate.server-cert.arn 
  vpc_id = var.vpn-vpc-id
  client_cidr_block = var.client-cidr-block 
  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn-cert-root.arn
  }
  connection_log_options {
    enabled = true 
    cloudwatch_log_group = aws_cloudwatch_log_group.this.id
  }
  transport_protocol = "udp" # we wil use this protocol for fast and smooth operation
  dns_servers = [ "10.0.0.2" ] # vpc will resolve dns ..this is for vpc dns resolver in it
  tags = {
    environemnt = var.env 
    Name = "${var.env}_vpn"
  }
}

#now we attach our vpn to a private subnet.. we will use the all private subnet to for HA 
resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(var.vpn-subents)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id 
  subnet_id = each.value #each subnet id 
  
}
#now we authorize group to vpn 
resource "aws_ec2_client_vpn_authorization_rule" "this" {
  target_network_cidr = var.vpn-vpc-cidr 
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id 
  authorize_all_groups = true 
}

#===============
#creating the server and client certificate for mutual tls verification 
#==================== 

#creating the aws certificate authority
#this contain a private key, certificate identity, certificate signing etc
resource "aws_acmpca_certificate_authority" "this" {
  type = "ROOT"
  permanent_deletion_time_in_days = 7 # should be incremented to desire 
  certificate_authority_configuration {
    key_algorithm = "RSA_2048" #this private key type
    signing_algorithm = "SHA256WITHRSA" #The signing algorithm for our certificate 
    subject {
      organization = "project-a-kubernetes"
      common_name = "vpn.project-a"
      country = "US"
    }
  }
  tags = {
    environment = var.env 
    Name = "${var.env}-project-a-acm"
  }
}

#now we create the root-certificate for the CA
resource "aws_acmpca_certificate" "root-cert" {
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn 
  certificate_signing_request = aws_acmpca_certificate_authority.this.certificate_signing_request #CA sign its own root certificate
  signing_algorithm = "SHA256WITHRSA"
  template_arn = "arn:aws:acm-pca:::template/RootCACertificate/V1" #this is aws own proedefined cert template arn
  validity {
    type = "MONTHS" #this should be "YEARS" for long time infra
    value = 120 #and this should be 10 years or more for long time infra
  }
} 

#now we associate the root-certificate to the acmpa  for activation 
resource "aws_acmpca_certificate_authority_certificate" "this" {
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn 
  certificate = aws_acmpca_certificate.root-cert.certificate 
  certificate_chain = aws_acmpca_certificate.root-cert.certificate_chain
}

#now that we have create the amcpa and attached a root certificate to validate it , we creat server cert,root cert and client cert... 
#creating cert for root_certificate_chain 
resource "aws_acm_certificate" "vpn-cert-root" {
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn #my acmpca will validate this cert
  domain_name = "vpn.cert.internal"
  tags = {
    environemnt = var.env
    Name = "${var.env}-vpn-certificate"
  }
} 
#now we create server certificate for the vpn endpoint  
resource "aws_acm_certificate" "server-cert" {
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn #my acmpca will validate this cert
  domain_name = "vpn.server-cert.internal"
  tags = {
    environemnt = var.env
    Name = "${var.env}-server-certificate"
  }
} 

#now we create the client  certificate for our K8s user 
resource "aws_acm_certificate" "client-cert" {
  for_each = toset(var.vpn-client)  #this will take a list of different users or engineers 
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn #my acmpca wil sign and validate this cert
  domain_name = "vpn.${each.key}-cert.internal" 
  tags = {
    environemnt = var.env 
    Name = "${var.env}-client-cert"
  }
} 

