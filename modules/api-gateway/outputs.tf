output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway stage"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.main.stage_name
}

output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint for API Gateway"
  value       = var.enable_vpc_endpoint ? aws_vpc_endpoint.api_gateway[0].id : null
}

output "vpc_endpoint_dns_names" {
  description = "DNS names of the VPC endpoint for API Gateway"
  value       = var.enable_vpc_endpoint ? aws_vpc_endpoint.api_gateway[0].dns_entry : null
}

output "health_endpoint_url" {
  description = "URL of the health check endpoint"
  value       = "${aws_api_gateway_stage.main.invoke_url}/health"
}