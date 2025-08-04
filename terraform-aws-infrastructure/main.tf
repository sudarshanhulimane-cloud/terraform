# AWS Infrastructure Terraform Configuration
# This configuration creates a complete AWS infrastructure with modular components

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
  region = var.aws_region
  
  default_tags {
    tags = var.common_tags
  }
}

# Data sources for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# IAM Module - Created first as other modules depend on it
module "iam" {
  source = "./modules/iam"
  
  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = data.aws_availability_zones.available.names
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway
  common_tags          = var.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"
  
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.networking.vpc_id
  vpc_cidr        = module.networking.vpc_cidr
  allowed_ssh_ips = var.allowed_ssh_ips
  common_tags     = var.common_tags
  
  depends_on = [module.networking]
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"
  
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  security_group_id    = module.security.rds_security_group_id
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  multi_az             = var.db_multi_az
  backup_retention     = var.db_backup_retention
  common_tags          = var.common_tags
  
  depends_on = [module.networking, module.security]
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load-balancer"
  
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  public_subnet_ids    = module.networking.public_subnet_ids
  security_group_id    = module.security.alb_security_group_id
  certificate_arn      = var.ssl_certificate_arn
  common_tags          = var.common_tags
  
  depends_on = [module.networking, module.security]
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  
  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_subnet_ids        = module.networking.private_subnet_ids
  bastion_security_group_id = module.security.bastion_security_group_id
  app_security_group_id     = module.security.app_security_group_id
  ec2_instance_profile_name = module.iam.ec2_instance_profile_name
  key_pair_name             = var.key_pair_name
  bastion_instance_type     = var.bastion_instance_type
  app_instance_type         = var.app_instance_type
  app_min_size              = var.app_min_size
  app_max_size              = var.app_max_size
  app_desired_capacity      = var.app_desired_capacity
  target_group_arn          = module.load_balancer.target_group_arn
  common_tags               = var.common_tags
  
  depends_on = [module.networking, module.security, module.iam, module.load_balancer]
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  public_subnet_ids          = module.networking.public_subnet_ids
  eks_security_group_id      = module.security.eks_security_group_id
  eks_cluster_role_arn       = module.iam.eks_cluster_role_arn
  eks_node_group_role_arn    = module.iam.eks_node_group_role_arn
  kubernetes_version         = var.kubernetes_version
  node_group_instance_types  = var.node_group_instance_types
  node_group_capacity_type   = var.node_group_capacity_type
  node_group_scaling_config  = var.node_group_scaling_config
  common_tags                = var.common_tags
  
  depends_on = [module.networking, module.security, module.iam]
}

# DNS Module
module "dns" {
  source = "./modules/dns"
  
  project_name    = var.project_name
  environment     = var.environment
  domain_name     = var.domain_name
  alb_dns_name    = module.load_balancer.alb_dns_name
  alb_zone_id     = module.load_balancer.alb_zone_id
  bastion_public_ip = module.compute.bastion_public_ip
  common_tags     = var.common_tags
  
  depends_on = [module.load_balancer, module.compute]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  project_name              = var.project_name
  environment               = var.environment
  bastion_instance_id       = module.compute.bastion_instance_id
  auto_scaling_group_name   = module.compute.auto_scaling_group_name
  eks_cluster_name          = module.eks.cluster_name
  rds_instance_id           = module.database.db_instance_id
  alb_arn_suffix            = module.load_balancer.alb_arn_suffix
  target_group_arn_suffix   = module.load_balancer.target_group_arn_suffix
  common_tags               = var.common_tags
  
  depends_on = [module.compute, module.eks, module.database, module.load_balancer]
}