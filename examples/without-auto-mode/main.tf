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
  region = "us-west-2"
}

# EKS infrastructure without Auto Mode (using traditional node groups)
module "eks_infrastructure" {
  source = "../../"

  name   = "traditional-eks"
  region = "us-west-2"

  # VPC Configuration
  vpc_cidr = "10.1.0.0/16"

  # EKS Configuration - Disable Auto Mode
  enable_eks_auto_mode = false
  enable_fargate      = false

  # Node Group Configuration
  node_group_instance_types   = ["t3.medium", "t3.large"]
  node_group_desired_capacity = 3
  node_group_max_capacity     = 6
  node_group_min_capacity     = 2

  # Security - Allow SSH access (update with your IP)
  allowed_ssh_cidrs = ["0.0.0.0/0"] # WARNING: Change this to your IP

  tags = {
    Terraform   = "true"
    Environment = "production"
    NodeType    = "traditional"
  }
}