# Terraform AWS Infrastructure - Folder Structure

```
terraform-aws-infrastructure/
├── main.tf                          # Root main configuration
├── variables.tf                     # Root variables
├── outputs.tf                       # Root outputs
├── terraform.tf                     # Terraform configuration
├── versions.tf                      # Provider versions
├── .gitignore                       # Git ignore file
├── README.md                        # Project documentation
├── examples/                        # Example configurations
│   ├── basic/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── production/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── vpc/                        # Networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security-groups/             # Security Groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/                     # Compute Resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── load-balancer/               # Application Load Balancer
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks-cluster/                 # EKS Cluster
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks-iam/                     # EKS IAM Roles
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/                     # S3 and EBS
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── database/                    # RDS Database
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── dns/                         # Route 53
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── monitoring/                  # CloudWatch
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/                         # IAM Roles and Policies
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── terraform.tfvars.example         # Example variables file
```

## Module Descriptions

### Core Infrastructure
- **vpc**: VPC, subnets, internet gateway, NAT gateway, route tables
- **security-groups**: All security groups for different components
- **compute**: EC2 instances, bastion host, auto scaling groups
- **load-balancer**: Application Load Balancer, target groups, listeners
- **eks-cluster**: EKS cluster and node groups
- **eks-iam**: IAM roles for EKS control plane and workers
- **storage**: S3 buckets and EBS volumes
- **database**: RDS instances with parameter groups
- **dns**: Route 53 hosted zones and records
- **monitoring**: CloudWatch log groups and alarms
- **iam**: IAM roles and policies for various services

### Features
- Modular design with clear separation of concerns
- Configurable variables for all components
- Comprehensive tagging strategy
- Security best practices
- Multi-AZ deployment support
- Monitoring and alerting integration