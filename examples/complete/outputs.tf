output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_infrastructure.cluster_endpoint
}

output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks_infrastructure.cluster_id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.eks_infrastructure.vpc_id
}

output "api_gateway_url" {
  description = "URL of the API Gateway stage"
  value       = module.eks_infrastructure.api_gateway_url
}

output "health_endpoint_url" {
  description = "URL of the health check endpoint"
  value       = module.eks_infrastructure.health_endpoint_url
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = module.eks_infrastructure.kubectl_config_command
}