# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.name
  role_arn = var.cluster_service_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
    security_group_ids      = [var.cluster_security_group_id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # Enable EKS Auto Mode
  compute_config {
    enabled       = var.enable_auto_mode
    node_pools    = var.enable_auto_mode ? ["general-purpose"] : []
    node_role_arn = var.enable_auto_mode ? var.node_group_role_arn : null
  }

  # Enable cluster logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling
  depends_on = [
    var.cluster_service_role_arn,
  ]

  tags = merge(var.tags, {
    Name = var.name
    Type = "eks-cluster"
  })
}

# EKS Node Group (only if auto mode is disabled)
resource "aws_eks_node_group" "main" {
  count           = var.enable_auto_mode ? 0 : 1
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name}-node-group"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.node_group_instance_types

  scaling_config {
    desired_size = var.node_group_desired_capacity
    max_size     = var.node_group_max_capacity
    min_size     = var.node_group_min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling
  depends_on = [
    var.node_group_role_arn,
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-node-group"
    Type = "eks-node-group"
  })
}

# Fargate Profile for kube-system namespace
resource "aws_eks_fargate_profile" "kube_system" {
  count                  = var.enable_fargate ? 1 : 0
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.name}-kube-system"
  pod_execution_role_arn = var.fargate_pod_execution_role_arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "kube-system"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-kube-system-fargate"
    Type = "eks-fargate-profile"
  })
}

# Fargate Profile for default namespace
resource "aws_eks_fargate_profile" "default" {
  count                  = var.enable_fargate ? 1 : 0
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.name}-default"
  pod_execution_role_arn = var.fargate_pod_execution_role_arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "default"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-default-fargate"
    Type = "eks-fargate-profile"
  })
}

# Data source for OIDC issuer URL
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.name
}

# OIDC Provider for EKS
data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = merge(var.tags, {
    Name = "${var.name}-eks-irsa"
    Type = "eks-oidc-provider"
  })
}

# CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name}-eks-logs"
    Type = "eks-cluster-logs"
  })
}