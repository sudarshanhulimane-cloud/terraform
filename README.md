# Terraform EKS Infrastructure Modules

A comprehensive, modular Terraform setup for creating AWS EKS infrastructure with best practices and reasonable defaults.

## 🏗️ Architecture

This Terraform module creates a complete EKS infrastructure including:

- **VPC Module**: VPC, subnets (public/private), Internet Gateway, NAT Gateway, route tables
- **Security Groups Module**: Security groups for EKS cluster, nodes, ALB, and API Gateway
- **EKS IAM Module**: IAM roles and policies for EKS cluster, node groups, and AWS Load Balancer Controller
- **EKS Cluster Module**: EKS cluster with Auto Mode support, Fargate profiles, and OIDC provider
- **API Gateway Module**: REST API Gateway with VPC endpoint and health check endpoint

## 🚀 Features

- **EKS Auto Mode**: Latest EKS Auto Mode for simplified node management
- **Multi-AZ Support**: Automatically distributes across 2 availability zones
- **Random CIDR Generation**: Intelligent CIDR block generation to avoid conflicts
- **Modular Design**: Each component is a separate module for maximum reusability
- **Security Best Practices**: Least privilege security groups and IAM policies
- **Fargate Support**: Optional Fargate profiles for serverless containers
- **API Gateway Integration**: Optional API Gateway with VPC endpoint
- **Comprehensive Outputs**: All necessary outputs for integration with other systems

## 📋 Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- kubectl (for cluster management)

## 🔧 Quick Start

### Minimal Setup (with all defaults)

```hcl
module "eks_infrastructure" {
  source = "./path/to/this/module"

  name   = "my-eks-cluster"
  region = "us-west-2"

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

This creates:
- VPC with random CIDR (10.X.0.0/16)
- 2 public and 2 private subnets across 2 AZs
- EKS cluster with Auto Mode enabled
- Fargate profiles for kube-system and default namespaces
- API Gateway with health check endpoint
- All necessary security groups and IAM roles

### Complete Setup (all options)

```hcl
module "eks_infrastructure" {
  source = "./path/to/this/module"

  name   = "production-eks"
  region = "us-west-2"

  # VPC Configuration
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]
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
  allowed_ssh_cidrs = ["10.0.0.0/16"]

  tags = {
    Terraform   = "true"
    Environment = "production"
    Project     = "my-project"
  }
}
```

## 📁 Module Structure

```
.
├── modules/
│   ├── vpc/                    # VPC, subnets, IGW, NAT, routes
│   ├── security-groups/        # Security groups for all components
│   ├── eks-iam/               # IAM roles and policies
│   ├── eks-cluster/           # EKS cluster with Auto Mode
│   └── api-gateway/           # API Gateway with VPC endpoint
├── examples/
│   ├── complete/              # Complete example with all features
│   ├── minimal/               # Minimal example with defaults
│   └── without-auto-mode/     # Traditional node groups example
├── main.tf                    # Root module orchestration
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
└── README.md                  # This file
```

## 📝 Examples

### 1. Complete Example
See `examples/complete/` for a full-featured setup.

### 2. Minimal Example
See `examples/minimal/` for the simplest possible setup.

### 3. Without Auto Mode
See `examples/without-auto-mode/` for traditional node group setup.

## 🔄 Usage

1. **Clone or copy this module structure**
2. **Navigate to your chosen example or create your own configuration**
3. **Initialize Terraform:**
   ```bash
   terraform init
   ```
4. **Plan the deployment:**
   ```bash
   terraform plan
   ```
5. **Apply the configuration:**
   ```bash
   terraform apply
   ```
6. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

## 📊 Outputs

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | EKS cluster endpoint |
| `cluster_id` | EKS cluster name/ID |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `api_gateway_url` | API Gateway URL (if enabled) |
| `health_endpoint_url` | Health check endpoint URL |
| `kubectl_config_command` | Command to configure kubectl |

## ⚙️ Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `name` | Name prefix for all resources | `string` |
| `region` | AWS region | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `vpc_cidr` | CIDR block for VPC | `string` | `"10.0.0.0/16"` |
| `cluster_version` | Kubernetes version | `string` | `"1.31"` |
| `enable_eks_auto_mode` | Enable EKS Auto Mode | `bool` | `true` |
| `enable_fargate` | Enable Fargate profiles | `bool` | `true` |
| `enable_api_gateway` | Enable API Gateway | `bool` | `true` |
| `enable_nat_gateway` | Enable NAT Gateway | `bool` | `true` |
| `single_nat_gateway` | Use single NAT Gateway | `bool` | `false` |

See `variables.tf` for complete list of variables.

## 🔒 Security Considerations

- **Network Security**: Private subnets for EKS nodes, public subnets for load balancers
- **IAM Roles**: Least privilege IAM roles for all components
- **Security Groups**: Restrictive security groups with minimal required access
- **API Gateway**: VPC endpoint for private API access
- **SSH Access**: Configurable SSH access restrictions

## 🔧 Customization

### Adding Custom Security Group Rules

Extend the security groups module in `modules/security-groups/main.tf`:

```hcl
resource "aws_security_group_rule" "custom_rule" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.eks_nodes.id
}
```

### Custom Node Group Configuration

When `enable_eks_auto_mode = false`, customize node groups in the EKS cluster module.

### API Gateway Customization

Add custom API Gateway resources in `modules/api-gateway/main.tf`.

## 🛠️ Troubleshooting

### Common Issues

1. **CIDR Conflicts**: Use different CIDR blocks if you have existing VPCs
2. **Region-specific AZs**: Ensure availability zones exist in your chosen region
3. **IAM Permissions**: Ensure your AWS credentials have sufficient permissions
4. **Auto Mode Support**: EKS Auto Mode requires specific regions and versions

### Debug Commands

```bash
# Check cluster status
aws eks describe-cluster --name <cluster-name> --region <region>

# Verify node groups (when auto mode disabled)
aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name>

# Check API Gateway
aws apigateway get-rest-apis --region <region>

# Test health endpoint
curl <health-endpoint-url>
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🔗 Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Auto Mode Documentation](https://docs.aws.amazon.com/eks/latest/userguide/automode.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)

---

**Note**: This is a production-ready setup, but always review security settings and customize according to your specific requirements before deploying to production environments.