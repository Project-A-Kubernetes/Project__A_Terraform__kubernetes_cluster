#creating the cluster 
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster-name
  version  = var.cluster-version
  role_arn = var.cluster-role
  vpc_config {
    subnet_ids              = var.cluster-subnet
    endpoint_private_access = true # we vant private network access access only so the cluster is not expose at any point
    endpoint_public_access  = false
    security_group_ids = [ aws_security_group.cluster.id ]
  }
  #we apply KMS encryption to our eks etcd
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.cmk-key
    }
  }
  #this enable the cluster to start collect the defined kind of logs below
  enabled_cluster_log_types = [
    "audit",
    "scheduler",
    "controllerManager",
    "authenticator",
    "api"
  ]
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  
  tags = {
    Name = "${var.cluster-name}_${var.env}"
  }
  depends_on = [var.wokernode-policy-cni, var.wokernode-policy-ecr, var.wokernode-policy-node-policy]
}

#collect data from the cluster 
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.cluster.name
}
#collect auth data from the cluster
data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.cluster.name
}
#create the oidc for my cluster, this resources will be consumed by the cluster resources and non cluster resoures..
resource "aws_iam_openid_connect_provider" "oidc" {
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls.certificates[0].sha1_fingerprint]
   lifecycle {
    # with this added terraform will not just want to delete the whole resources because something small was changed
    ignore_changes = [ 
      url,
      thumbprint_list,
      tags_all
    ]
  }
}
#getting the tls_cert thumbprint 
data "tls_certificate" "tls" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

#control plane sg 
resource "aws_security_group" "cluster" {
  vpc_id = var.sg-vpc
  ingress {
    from_port = 443 
    to_port = 443
    protocol = "tcp"
    description = "This give the vpn access to my api server as api server is the only cluster access point"
    security_groups = [ var.vpn-sg ]
  }
  ingress {
    from_port = 443 
    to_port = 443 
    protocol = "tcp"
    description = "we open port 443 for workernode to communicate with api server"
    security_groups = [aws_security_group.workernodesg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#=============
#create managed_workernode 
#================ 

#The workernode 
resource "aws_eks_node_group" "workernode" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.workernode-name
  node_role_arn   = var.workernode-role
  subnet_ids      = var.workernode-subnet
  instance_types  = ["t3.small"]
  #disk_size = var.disk-size can be added to cluster but i use the default size of 20GB
  #we can config a security-group,minimux launch template for the node_group but we will let aws do that
  scaling_config {
    desired_size = 2
    max_size     = 6
    min_size     = 2
  }
 
  update_config {
    max_unavailable = 1
  }
  labels = {
    type = var.env
  }
  tags = {
    environemnt = var.env
    Name        = var.workernode-name
  }
  tags_all = {
    "kubernetes.io/cluster/$(var.cluster-name)" = "owned"
  }
launch_template {
  id = aws_launch_template.worker_lt.id 
  version = "$Latest"
}
}
resource "aws_launch_template" "worker_lt" {
  name_prefix   = "eks-worker-"
  vpc_security_group_ids = [
    aws_security_group.workernodesg.id
  ]
}
# workernode security
resource "aws_security_group" "workernodesg" {
  name   = "mysql-security-g"
  vpc_id = var.sg-vpc
  ingress {
      to_port          = 0
      from_port        = 0
      protocol         = "-1"
      description      = "The inbound rule for all inbound within the vpc internal"
      cidr_blocks =  [ var.worker-cidr-blocks ] 
  }
  ingress {
    from_port = 10250 
    to_port = 10250 
    protocol = "tcp"
    description = "this give my api server access to speak to my workenode maybe i want to run K exec or other access type"
    cidr_blocks = [ var.worker-cidr-blocks ]
  } 

  ingress {
    from_port = 30000 
    to_port = 32767 
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "This allow argocd ALB to speak with workernode from outside, we use specific port only"
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.workernode-name}-SG"
  }
} 

#===========
#EKS addons 
#================== 

resource "aws_eks_addon" "this" {
  cluster_name = aws_eks_cluster.cluster.id 
  addon_name = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn = var.ebs-csi-role 
}