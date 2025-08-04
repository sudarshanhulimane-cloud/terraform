# AWS Infrastructure with Terraform

A comprehensive, modular Terraform configuration for deploying a complete AWS infrastructure including VPC, EC2, EKS, RDS, ALB, and monitoring components.

## 📁 Project Structure

```
terraform-aws-infrastructure/
├── README.md
├── main.tf                           # Root configuration
├── variables.tf                      # Root variables
├── outputs.tf                        # Root outputs
├── terraform.tfvars.example          # Example variable values
├── environments/
│   └── dev/                          # Environment-specific configurations
└── modules/
    ├── networking/                   # VPC, subnets, gateways
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/                     # Security groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                          # IAM roles and policies
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/                      # EC2, ASG, bastion host
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── user_data_bastion.sh
    │   └── user_data_app.sh
    ├── load-balancer/                # Application Load Balancer
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/                          # Amazon EKS cluster
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── eks_node_userdata.sh
    ├── storage/                      # S3 bucket, EBS volumes
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── database/                     # RDS PostgreSQL/MySQL
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── dns/                          # Route 53 hosted zone
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── monitoring/                   # CloudWatch logs and alarms
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 🏗️ Infrastructure Components

### 1. **Networking**
- VPC with configurable CIDR
- 2 public subnets and 2 private subnets across 2 AZs
- Internet Gateway
- NAT Gateway (configurable)
- Route Tables for public and private subnets
- DHCP Options Set

### 2. **Security**
- **Bastion Host Security Group**: SSH access from configurable IPs
- **ALB Security Group**: HTTP/HTTPS from anywhere
- **Application Security Group**: Access from ALB and bastion
- **EKS Security Groups**: Cluster and worker node communication
- **RDS Security Group**: Database access from app servers and EKS

### 3. **IAM**
- EC2 instance roles with S3 and CloudWatch permissions
- EKS cluster service role
- EKS node group role with required policies
- RDS monitoring role

### 4. **Compute**
- **Bastion Host**: Secure access point with management tools
- **Auto Scaling Group**: Application servers with auto-scaling policies
- **Launch Template**: Configurable EC2 instances with user data
- Integrated CloudWatch monitoring

### 5. **Load Balancing**
- Application Load Balancer in public subnets
- Target Groups with health checks
- HTTP to HTTPS redirect (when SSL certificate provided)
- Access logs stored in S3

### 6. **Container Platform**
- **Amazon EKS Cluster**: Managed Kubernetes
- **EKS Node Groups**: Managed worker nodes
- **EKS Add-ons**: VPC CNI, CoreDNS, Kube-proxy, EBS CSI driver
- OIDC provider for service accounts

### 7. **Storage**
- **S3 Bucket**: Versioned and encrypted storage
- **EBS Volumes**: Optional additional storage
- Lifecycle policies for cost optimization

### 8. **Database**
- **RDS Instance**: PostgreSQL or MySQL
- Parameter groups for optimization
- Subnet groups for network isolation
- Optional read replicas
- Secrets Manager integration
- Enhanced monitoring

### 9. **DNS & Routing**
- **Route 53 Hosted Zone**: Domain management
- A records for ALB and bastion host
- Health checks and monitoring
- Support for custom subdomains

### 10. **Monitoring**
- **CloudWatch Log Groups**: Centralized logging
- **CloudWatch Alarms**: CPU, memory, disk, and application metrics
- **CloudWatch Dashboard**: Visual monitoring
- **SNS Integration**: Alert notifications

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS Key Pair** created for EC2 access

### 1. Clone and Setup

```bash
git clone <repository-url>
cd terraform-aws-infrastructure
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
# Required Variables
aws_region      = "us-west-2"
project_name    = "my-aws-project"
environment     = "dev"
key_pair_name   = "my-key-pair"     # Create this in AWS first

# Security
allowed_ssh_ips = ["YOUR_IP/32"]    # Replace with your IP

# Database
db_password = "SecurePassword123!"  # Use a strong password

# Optional: Domain and SSL
domain_name         = "example.com"
ssl_certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/..."
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 4. Access Your Infrastructure

After deployment, you'll receive outputs including:
- ALB DNS name for your application
- Bastion host IP for secure access
- EKS cluster name for kubectl configuration
- RDS endpoint (stored in Secrets Manager)

## 🔧 Configuration Options

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for deployment | `us-west-2` | No |
| `project_name` | Project name for resource naming | `aws-infrastructure` | No |
| `environment` | Environment (dev/staging/prod) | `dev` | No |
| `key_pair_name` | AWS key pair for EC2 access | - | **Yes** |

### Networking Options

| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `public_subnet_cidrs` | Public subnet CIDRs | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | Private subnet CIDRs | `["10.0.10.0/24", "10.0.20.0/24"]` |
| `enable_nat_gateway` | Enable NAT Gateway | `true` |

### Compute Options

| Variable | Description | Default |
|----------|-------------|---------|
| `bastion_instance_type` | Bastion instance type | `t3.micro` |
| `app_instance_type` | Application instance type | `t3.medium` |
| `app_min_size` | ASG minimum instances | `1` |
| `app_max_size` | ASG maximum instances | `5` |
| `app_desired_capacity` | ASG desired instances | `2` |

### Database Options

| Variable | Description | Default |
|----------|-------------|---------|
| `db_engine` | Database engine (postgres/mysql) | `postgres` |
| `db_instance_class` | RDS instance class | `db.t3.micro` |
| `db_allocated_storage` | Storage size (GB) | `20` |
| `multi_az` | Enable Multi-AZ | `false` |

## 🔒 Security Best Practices

### 1. **Network Security**
- Private subnets for application and database tiers
- Security groups with principle of least privilege
- Bastion host for secure access

### 2. **Data Protection**
- Encryption at rest for all storage (EBS, S3, RDS)
- Secrets Manager for database credentials
- SSL/TLS encryption in transit

### 3. **Access Control**
- IAM roles with minimal required permissions
- No hardcoded credentials
- Key-based SSH access

### 4. **Monitoring**
- CloudWatch logging for all components
- Automated alerting for security events
- Regular security monitoring

## 🔄 EKS Access

After deployment, configure kubectl to access your EKS cluster:

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name my-aws-project-dev-eks

# Verify access
kubectl get nodes
```

## 📊 Monitoring and Logs

### CloudWatch Dashboard
Access your monitoring dashboard at:
```
https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards
```

### Log Groups
- `/aws/ec2/{project}-{env}-bastion` - Bastion host logs
- `/aws/ec2/{project}-{env}-app` - Application server logs
- `/aws/eks/{project}-{env}/cluster` - EKS cluster logs
- `/aws/eks/{project}-{env}/nodes` - EKS node logs

## 🧹 Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Note**: This will delete all resources. Ensure you have backups of any important data.

## 🔧 Customization

### Adding New Modules
1. Create a new module directory under `modules/`
2. Add `main.tf`, `variables.tf`, and `outputs.tf`
3. Reference the module in the root `main.tf`

### Environment-Specific Configurations
1. Create directories under `environments/` for each environment
2. Use Terraform workspaces or separate state files
3. Override variables as needed per environment

## 📋 Cost Optimization

### Development Environment
- Use `t3.micro` instances
- Disable Multi-AZ for RDS
- Use GP3 storage types
- Enable scheduled scaling for non-production hours

### Production Environment
- Use appropriate instance sizes based on load
- Enable Multi-AZ for high availability
- Implement automated backups
- Use Reserved Instances for cost savings

## 🐛 Troubleshooting

### Common Issues

1. **Key Pair Not Found**
   - Ensure the key pair exists in the specified AWS region
   - Update `key_pair_name` variable

2. **Insufficient Permissions**
   - Verify AWS credentials have required permissions
   - Check IAM policies for Terraform deployment

3. **Resource Limits**
   - Check AWS service limits (VPC, EIP, etc.)
   - Request limit increases if needed

4. **EKS Node Group Issues**
   - Verify IAM roles have required policies
   - Check subnet configurations and routing

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS CloudTrail logs
3. Examine Terraform state and plan outputs
4. Consult AWS documentation for service-specific issues

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Important**: This infrastructure creates billable AWS resources. Monitor your AWS costs and clean up resources when not needed.