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

# Minimal EKS infrastructure with default settings
module "eks_infrastructure" {
  source = "../../"

  name   = "minimal-eks"
  region = "us-west-2"

  # Use all defaults - will create:
  # - VPC with random CIDR
  # - 2 AZs with public/private subnets
  # - NAT Gateway
  # - EKS cluster with Auto Mode
  # - Fargate profiles
  # - API Gateway
  # - All necessary security groups and IAM roles

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}