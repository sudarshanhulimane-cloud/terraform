terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name                = var.name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  tags              = var.tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  name              = var.name
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.vpc_cidr_block
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  tags             = var.tags
}

# EKS IAM Roles Module
module "eks_iam" {
  source = "./modules/eks-iam"

  name = var.name
  tags = var.tags
}

# EKS Cluster Module
module "eks_cluster" {
  source = "./modules/eks-cluster"

  name                              = var.name
  cluster_version                  = var.cluster_version
  vpc_id                           = module.vpc.vpc_id
  subnet_ids                       = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  cluster_service_role_arn         = module.eks_iam.eks_cluster_role_arn
  node_group_role_arn              = module.eks_iam.eks_node_group_role_arn
  fargate_pod_execution_role_arn   = module.eks_iam.eks_fargate_pod_execution_role_arn
  cluster_security_group_id        = module.security_groups.eks_cluster_security_group_id
  node_security_group_id           = module.security_groups.eks_nodes_security_group_id
  cluster_endpoint_private_access  = var.cluster_endpoint_private_access
  cluster_endpoint_public_access   = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  enable_auto_mode                 = var.enable_eks_auto_mode
  enable_fargate                   = var.enable_fargate
  node_group_instance_types        = var.node_group_instance_types
  node_group_desired_capacity      = var.node_group_desired_capacity
  node_group_max_capacity          = var.node_group_max_capacity
  node_group_min_capacity          = var.node_group_min_capacity
  tags                            = var.tags

  depends_on = [
    module.eks_iam,
    module.security_groups
  ]
}

# API Gateway Module (optional)
module "api_gateway" {
  count  = var.enable_api_gateway ? 1 : 0
  source = "./modules/api-gateway"

  name               = var.name
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.api_gateway_vpc_endpoint_security_group_id]
  endpoint_type     = var.api_gateway_endpoint_type
  tags              = var.tags
}