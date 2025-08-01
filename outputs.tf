# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.availability_zones
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.eks_cluster.oidc_provider_arn
}

output "cluster_auto_mode_enabled" {
  description = "Whether EKS Auto Mode is enabled"
  value       = module.eks_cluster.cluster_auto_mode_enabled
}

# Security Groups Outputs
output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = module.security_groups.eks_cluster_security_group_id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = module.security_groups.eks_nodes_security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security_groups.alb_security_group_id
}

# IAM Outputs
output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster service role"
  value       = module.eks_iam.eks_cluster_role_arn
}

output "eks_node_group_role_arn" {
  description = "ARN of the EKS node group role"
  value       = module.eks_iam.eks_node_group_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller role"
  value       = module.eks_iam.aws_load_balancer_controller_role_arn
}

# API Gateway Outputs (conditional)
output "api_gateway_url" {
  description = "URL of the API Gateway stage"
  value       = var.enable_api_gateway ? module.api_gateway[0].api_gateway_url : null
}

output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = var.enable_api_gateway ? module.api_gateway[0].api_gateway_id : null
}

output "health_endpoint_url" {
  description = "URL of the health check endpoint"
  value       = var.enable_api_gateway ? module.api_gateway[0].health_endpoint_url : null
}

# Kubectl Config Command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks_cluster.cluster_id}"
}