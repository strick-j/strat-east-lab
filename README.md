# Strat East Lab

A comprehensive Terraform infrastructure-as-code project that deploys an integrated AWS cloud environment with CyberArk Identity Security and Privileged Access Management (PAM) capabilities.

## Overview

This project demonstrates how to build a secure, enterprise-grade lab environment that combines AWS infrastructure with CyberArk's identity and privilege access management solutions. The infrastructure is deployed in a modular, stage-gated approach that ensures dependencies are properly managed.

## Architecture

The lab environment includes:

- **AWS Foundation**: VPC networking with public/private subnets, NAT Gateway, security groups, and S3 storage
- **AWS Security**: IAM roles and policies for EC2 and CyberArk Secrets Hub integration
- **CyberArk Foundation**: Identity roles, Privilege Cloud safes, and credential management infrastructure
- **CyberArk Compute**: EC2 instances with Secure Infrastructure Access (SIA) connector integration

## Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads) >= 1.3.0
- [TFLint](https://github.com/terraform-linters/tflint) (optional, for code quality)
- AWS CLI configured with appropriate credentials
- CyberArk Identity tenant and API credentials

### Required Access
- AWS account with permissions to create VPCs, EC2 instances, IAM roles, and S3 buckets
- CyberArk Identity tenant with administrative access
- CyberArk Privilege Cloud access (for safe and account management)

### Provider Versions
- AWS Provider: ~> 5.36
- CyberArk Identity Security Provider: ~> 0.1.8
- Conjur Provider: ~> 0.8.1

## Module Structure

The project is organized into seven sequential deployment modules:

```
terraform_code/
├── 01_aws_foundation/           # Base AWS infrastructure
├── 02_aws_security/             # IAM roles and policies
├── 03_identity_users/           # CyberArk Identity user provisioning
├── 04_identity_roles/           # CyberArk Identity role management
├── 05_privilege_cloud_safes/    # Privilege Cloud safe creation and role mapping
├── 06_cyberark_foundation/      # CyberArk connector and network configuration
└── 07_cyberark_compute/         # Compute resources with SIA connector
```

### Module 01: AWS Foundation

Creates the foundational AWS infrastructure including:

**Networking**
- VPC with configurable CIDR (default: 192.168.0.0/16)
- Public subnet (192.168.50.0/24) in us-east-2a
- Private subnet (192.168.20.0/24) in us-east-2b
- Internet Gateway and NAT Gateway
- Route tables with S3 VPC endpoint
- DHCP options for domain integration

**Security Groups**
- SSH/RDP access (external and internal)
- WinRM for Windows management
- HTTPS and Jenkins web access
- Domain Controller (Active Directory/DNS ports)
- Database access (MySQL, PostgreSQL, MSSQL)
- SIA Windows target access

**Storage**
- S3 bucket for automation artifacts
- Public access blocked
- VPC endpoint and trusted IP restrictions

### Module 02: AWS Security

Establishes AWS identity and access management:

- **EC2 ASM Role**: Allows EC2 instances to access Secrets Manager and assume roles
- **Secrets Hub Onboarding Role**: Integrates AWS account with CyberArk Secrets Hub

### Module 03: Identity Users

Provisions CyberArk Identity users:

- User creation with email and mobile number
- Configurable domain suffix
- Lifecycle management for user attributes
- Automated user provisioning from Conjur secrets
- Support for multiple users via list variable

### Module 04: Identity Roles

Creates CyberArk Identity roles for access management:

**User Roles** (5 roles)
- Windows Users
- Linux Users
- Database Users
- Kubernetes Users
- Cloud Users

**Admin Roles** (5 roles)
- Windows Admins
- Linux Admins
- Database Admins
- Kubernetes Admins
- Cloud Admins

**Privilege Cloud Safe Admin Role**
- Elevated permissions for safe management

All roles follow the naming convention: `{Alias} {Purpose} {Users|Admins}`

### Module 05: Privilege Cloud Safes

Creates Privilege Cloud safes and maps Identity roles to safes:

**Safe Creation** (13 safes)
- Windows Domain Service Accounts (PAP-WIN-DOM-SVC)
- Windows Domain Interactive Accounts (PAP-WIN-DOM-INT)
- Windows Domain Strong Accounts (PAP-WIN-DOM-STR)
- Windows Local Service Accounts (PAP-WIN-LOC-SVC)
- Windows Local Interactive Accounts (PAP-WIN-LOC-INT)
- Windows Local Strong Accounts (PAP-WIN-LOC-STR)
- Linux Local Accounts (PAP-NIX-LOC-INT)
- Database Local Accounts (PAP-DB-LOC-INT)
- Database Strong Accounts (PAP-DB-LOC-STR)
- Cloud Accounts for GCP (PAP-CLD-GCP-INT)
- Cloud Accounts for Azure (PAP-CLD-AZR-INT)
- Cloud Accounts for AWS (PAP-CLD-AWS-INT)
- Kubernetes Cluster Accounts (PAP-K8S-CLS-INT)

**Role Mapping**
- User roles mapped to matching safes with `connect_only` permissions
- Admin roles mapped to matching safes with `full` permissions
- Safe Admin role mapped to all safes with `full` permissions
- SIA roles (ephemeral and secrets access) mapped to all safes
- Automatic mapping based on safe purpose (WIN, NIX, DB, CLD, K8S)

**Examples:**
- "Papaya Windows Users" → All WIN safes (connect_only)
- "Papaya Windows Admins" → All WIN safes (full)
- "Papaya Database Users" → All DB safes (connect_only)
- "Papaya Database Admins" → All DB safes (full)

### Module 06: CyberArk Foundation

Configures CyberArk connector and network infrastructure:

**Connector Management**
- Network and pool configuration for AWS resources
- Pool identifiers based on AWS Account ID and VPC ID
- Integration with CyberArk Identity platform

### Module 07: CyberArk Compute

Deploys compute resources with CyberArk integration:

- Ubuntu 22.04 LTS EC2 instance in private subnet
- TLS RSA 4096-bit SSH key pair
- Private key stored in CyberArk Privilege Cloud
- CyberArk SIA connector installation
- Encrypted root volume (30GB gp3)

## Deployment

### Step 1: Configure Variables

Each module requires configuration. Create `terraform.tfvars` files or set environment variables for:

- AWS region and account details
- CyberArk tenant URL and credentials
- Project alias (naming prefix)
- Network CIDR ranges
- Trusted IP addresses

### Step 2: Deploy Modules Sequentially

Deploy modules in order, as each depends on outputs from previous modules:

```bash
# Module 1: AWS Foundation
cd terraform_code/01_aws_foundation
terraform init
terraform plan
terraform apply

# Module 2: AWS Security
cd ../02_aws_security
terraform init
terraform plan
terraform apply

# Module 3: Identity Users
cd ../03_identity_users
terraform init
terraform plan
terraform apply

# Module 4: Identity Roles
cd ../04_identity_roles
terraform init
terraform plan
terraform apply

# Module 5: Privilege Cloud Safes
cd ../05_privilege_cloud_safes
terraform init
terraform plan
terraform apply

# Module 6: CyberArk Foundation
cd ../06_cyberark_foundation
terraform init
terraform plan
terraform apply

# Module 7: CyberArk Compute
cd ../07_cyberark_compute
terraform init
terraform plan
terraform apply
```

### Step 3: Verify Deployment

After deployment, verify:
- AWS resources in the AWS Console
- Security groups and network connectivity
- IAM roles and policies
- CyberArk Identity roles and safes
- EC2 instance accessibility through CyberArk SIA

## Configuration

### Remote State

All modules use S3-backed remote state for dependency management:
- State files stored in: `s3://bucket-name/terraform/*.tfstate`
- Enables cross-module data sharing

### Naming Convention

Resources follow a consistent naming pattern using a project alias:
- AWS resources: lowercase alias (e.g., `papaya-vpc`)
- CyberArk safes: uppercase alias (e.g., `PAPAYA-Windows-Accounts`)

### Security Best Practices

The project implements several security best practices:
- Private keys with 0600 permissions
- Encrypted EBS volumes
- Restricted security group ingress rules
- Public access blocked on S3 buckets
- VPC endpoint restrictions
- Secrets stored in CyberArk Privilege Cloud

### Tagging Strategy

All resources are tagged with:
- `Owner`: Asset owner contact information
- `Name`: Descriptive resource name
- `Project`/`Alias`: Project identifier
- `Purpose`: Resource intent (I_Purpose tag)
- CloudApper tags (if applicable)

## Code Quality

The project includes TFLint configuration for maintaining code quality:

```bash
# Run TFLint
cd terraform_code
tflint --recursive
```

**Enabled Rules:**
- Terraform recommended preset
- AWS plugin checks
- Naming convention enforcement (snake_case)

## Technology Stack

- **Infrastructure**: AWS (VPC, EC2, IAM, S3)
- **Identity & Access**: CyberArk Identity Security Platform
- **Secrets Management**: CyberArk Privilege Cloud, Conjur
- **Infrastructure as Code**: Terraform >= 1.3.0
- **Code Quality**: TFLint with AWS plugin

## Use Cases

This lab environment is ideal for:

- **Security Testing**: Test CyberArk integration with AWS workloads
- **Training**: Learn infrastructure deployment and privilege access management
- **POC Development**: Demonstrate CyberArk capabilities in AWS
- **CI/CD Integration**: Build automated deployment pipelines
- **Identity Governance**: Explore role-based access control patterns

## Contributing

When contributing to this project:

1. Follow the existing module structure
2. Use snake_case for variables and outputs
3. Run TFLint before committing
4. Update module documentation for significant changes
5. Test changes in a non-production environment

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please open an issue in the repository.

## Acknowledgments

This project demonstrates integration between:
- AWS cloud services
- CyberArk Identity Security Platform
- CyberArk Privilege Cloud
- CyberArk Secure Infrastructure Access (SIA)
