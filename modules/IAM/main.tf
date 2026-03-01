#creating the kubernete iam role 
#=============
#cluster role
#=============
resource "aws_iam_role" "kube-cluster-role" {
  name = var.role-name
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }]
    }
  )
  tags = {
    name        = "kube-cluster-role"
    environment = var.env
  }
}

#attach role to policy for my cluster
resource "aws_iam_role_policy_attachment" "role-policy" {
  role       = aws_iam_role.kube-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
#==========
#workernode role
#==========
resource "aws_iam_role" "workernode-role" {
  name = var.workernode-role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = {
    name        = "kube-workernode-role"
    environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "worker-policy" {
  role       = aws_iam_role.workernode-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "worker-cni" {
  role       = aws_iam_role.workernode-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "worker-ecr" {
  role       = aws_iam_role.workernode-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "ebsc" {
  role = aws_iam_role.workernode-role.name 
  policy_arn =  "arn:aws:iam::aws:policy/AmazonEC2FullAccess" # lab minimal real case create a policy with limited actions
}

#=================
#OIDC ROLE 
#==================== 

resource "aws_iam_role" "this" {
  name               = var.oidc-role
  assume_role_policy = data.aws_iam_policy_document.this.json
}
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc-ident-arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc-url, "https://", "")}:sub"
      values   = ["system:serviceaccount:production:kube-application"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc-url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
#attach policy to that oidc role for SA
resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.this.name
} 

#========
#ebs-csi-driver-role 
#=============== 
resource "aws_iam_role" "ebs-csi" {
  name               = "project-a-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.ebs.json 
}
data "aws_iam_policy_document" "ebs" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc-ident-arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc-url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc-url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ebs" {
  role = aws_iam_role.ebs-csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}