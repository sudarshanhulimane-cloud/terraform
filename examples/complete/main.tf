terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Complete EKS infrastructure with all components
module "eks_infrastructure" {
  source = "../../"

  name   = var.name
  region = var.region

  # VPC Configuration
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = true
  single_nat_gateway = false

  # EKS Configuration
  cluster_version                      = "1.31"
  enable_eks_auto_mode                = true
  enable_fargate                      = true
  cluster_endpoint_private_access     = true
  cluster_endpoint_public_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Node Group Configuration (when auto mode is disabled)
  node_group_instance_types   = ["t3.medium"]
  node_group_desired_capacity = 2
  node_group_max_capacity     = 4
  node_group_min_capacity     = 1

  # API Gateway Configuration
  enable_api_gateway         = true
  api_gateway_endpoint_type = "REGIONAL"

  # Security
  allowed_ssh_cidrs = var.allowed_ssh_cidrs

  tags = {
    Terraform   = "true"
    Environment = "production"
    Project     = "eks-infrastructure"
  }
}