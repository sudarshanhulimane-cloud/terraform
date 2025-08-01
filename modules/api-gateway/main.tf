# VPC Endpoint for API Gateway (if enabled)
resource "aws_vpc_endpoint" "api_gateway" {
  count = var.enable_vpc_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.execute-api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name}-api-gateway-vpce"
    Type = "api-gateway-vpce"
  })
}

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current caller identity
data "aws_caller_identity" "current" {}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.name}-api"
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  # Policy for private API (if using PRIVATE endpoint type)
  policy = var.endpoint_type == "PRIVATE" ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = var.enable_vpc_endpoint ? aws_vpc_endpoint.api_gateway[0].id : ""
          }
        }
      }
    ]
  }) : null

  tags = merge(var.tags, {
    Name = "${var.name}-api"
    Type = "api-gateway"
  })
}

# API Gateway Resource (example health check endpoint)
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "health"
}

# API Gateway Method for health check
resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration for health check
resource "aws_api_gateway_integration" "health_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# API Gateway Method Response for health check
resource "aws_api_gateway_method_response" "health_get_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = "200"

  response_headers = {
    "Access-Control-Allow-Headers" = true
    "Access-Control-Allow-Methods" = true
    "Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Integration Response for health check
resource "aws_api_gateway_integration_response" "health_get_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = aws_api_gateway_method_response.health_get_200.status_code

  response_headers = {
    "Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "API Gateway is healthy"
      timestamp = "$context.requestTime"
      requestId = "$context.requestId"
    })
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_method.health_get,
    aws_api_gateway_integration.health_get,
    aws_api_gateway_integration_response.health_get_200
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.health.id,
      aws_api_gateway_method.health_get.id,
      aws_api_gateway_integration.health_get.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  tags = merge(var.tags, {
    Name = "${var.name}-api-stage-${var.stage_name}"
    Type = "api-gateway-stage"
  })
}

# API Gateway Method Settings (Throttling)
resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    throttling_rate_limit  = var.throttle_rate_limit
    throttling_burst_limit = var.throttle_burst_limit
    logging_level         = "INFO"
    data_trace_enabled    = true
    metrics_enabled       = true
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.name}-api"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name}-api-logs"
    Type = "api-gateway-logs"
  })
}