#=============
#Production grade network setup 
#==========================

# These are the public and private AZ and cidr block
locals {
  public = {
    us-east-1d = "10.0.13.0/24"
    us-east-1c = "10.0.120.0/24"
    us-east-1f = "10.0.78.0/24"
  }
  private = {
    us-east-1d = "10.0.10.0/24"
    us-east-1c = "10.0.20.0/24"
    us-east-1f = "10.0.30.0/24"
  }


}
# this create a vpc 
resource "aws_vpc" "kube-net" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    environemnt = var.env
  }
}
# this create a public subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.kube-net.id
  map_public_ip_on_launch = true
  for_each                = local.public
  cidr_block              = each.value
  availability_zone       = each.key
  tags = {
    environemnt                               = var.env
    Name                                      = "${var.env}_public_subnet"
    "kubernetes.io/role/elb"                  = "1" #this allow elb use the subnet maybe like an ingress ALB
    "kubernetes.io/cluster/${var.vpc-cluster-name}" = "shared" #this tags make our LB pulic for internet facing LB
  }
}
# this create a private subnet 
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.kube-net.id
  for_each          = local.private
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    environemnt                               = var.env
    Name                                      = "${var.env}_private_subnet"
    "kubernetes.io/cluster/${var.vpc-cluster-name}" = "shared"
  }
}
#===========================
#Public subnet network configuration 
#===========================
# this create an internet gateway 
resource "aws_internet_gateway" "kube-igw" {
  vpc_id = aws_vpc.kube-net.id
  tags = {
    environemnt = var.env
    Name        = "kubernetes-IGW"
  }
}

#this create a route-table 
resource "aws_route_table" "kube-public-rt" {
  vpc_id = aws_vpc.kube-net.id
  tags = {
    environemnt = var.env
    Name        = "public-RT"
  }
}
# this create a route 
resource "aws_route" "kube-public-route" {
  route_table_id         = aws_route_table.kube-public-rt.id
  gateway_id             = aws_internet_gateway.kube-igw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public-kube-rt-as" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.kube-public-rt.id
}

# ======================
# private subnet network configuration
# =================== 
#this create the nat-gateway, we attach the Eip and public nat subnet which have a route to the internet
resource "aws_nat_gateway" "kube-private-nat" {
  allocation_id = aws_eip.kube-nat-ip[each.key].id
  for_each      = aws_subnet.public_subnet
  subnet_id     = each.value.id
  tags = {
    environemnt = var.env
    Name        = "kubernetes-nat-gateway"
  }
}
#This create an Elastic Ip used by the nat-gateway to reach the internet
resource "aws_eip" "kube-nat-ip" {
  for_each = aws_subnet.public_subnet
  domain   = "vpc"
  tags = {
    environemnt = var.env
    nameame        = "kubernetes-elastic-ip"
  }
}
#we create route, the route will be created in each AZ, in the private subnet but key reference to the same nat AZ
resource "aws_route" "kube-private-route" {
  for_each               = aws_subnet.private_subnet
  nat_gateway_id         = aws_nat_gateway.kube-private-nat[each.key].id
  route_table_id         = aws_route_table.kube-private-rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}
#we create a route-table 
resource "aws_route_table" "kube-private-rt" {
  for_each = aws_subnet.private_subnet
  vpc_id   = aws_vpc.kube-net.id
  tags = {
    environemnt = var.env
    Name = "private-RT"
  }
}
# with each private subnet here is where we associate the
resource "aws_route_table_association" "kube-private-rt-as" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.kube-private-rt[each.key].id
}