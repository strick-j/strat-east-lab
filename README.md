# Strat East Lab

A comprehensive Terraform infrastructure-as-code project that deploys an integrated AWS cloud environment with CyberArk Identity Security and Privileged Access Management (PAM) capabilities.

## Overview

This project demonstrates how to build a secure, enterprise-grade lab environment that combines AWS infrastructure with CyberArk's identity and privilege access management solutions. The infrastructure is deployed in a modular approach organized by domain (AWS and CyberArk), with cross-module dependencies managed through S3-backed remote state.

## Architecture

The lab environment includes:

- **AWS Networking**: VPC with public/private subnets, NAT Gateway, VPC peering, and S3 VPC endpoint
- **AWS Security**: Security groups, IAM roles, SSH key pair management
- **AWS Storage**: S3 bucket for automation artifacts with access restrictions
- **AWS Compute**: Windows and Linux target instances, SIA connectors, and Domain Controller
- **AWS RDS**: PostgreSQL database instances
- **CyberArk Identity**: User provisioning and role-based access management
- **CyberArk Privilege Cloud**: Safe creation with automated role-to-safe permission mapping
- **CyberArk CMGR**: Connector management network and pool configuration

## Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads) >= 1.3.0
- [TFLint](https://github.com/terraform-linters/tflint) (optional, for code quality)
- AWS CLI configured with appropriate credentials
- CyberArk Identity tenant and API credentials

### Required Access
- AWS account with permissions to create VPCs, EC2 instances, IAM roles, S3 buckets, and RDS instances
- CyberArk Identity tenant with administrative access
- CyberArk Privilege Cloud access (for safe and account management)

### Provider Versions
- AWS Provider: ~> 5.36
- CyberArk Identity Security Provider: ~> 0.1.12
- Conjur Provider: ~> 0.8.1

## Module Structure

The project is organized into two top-level domains with hierarchical sub-modules:

```
terraform_code/
├── .tflint.hcl                              # TFLint code quality configuration
├── aws/                                     # AWS infrastructure
│   ├── networking/                          # VPC, subnets, routing, peering
│   │   └── vpc/                             #   Core VPC child module
│   ├── security/                            # Security groups, IAM, key pairs
│   │   ├── iam_roles/
│   │   │   ├── ec2_asm_role/                #   EC2 Secrets Manager access role
│   │   │   └── secrets_hub_onboarding_role/ #   CyberArk Secrets Hub integration role
│   │   ├── key_pair/                        #   SSH key pair generation
│   │   └── security_groups/                 #   Network access control groups
│   ├── storage/                             # S3 bucket for automation artifacts
│   │   └── s3/                              #   S3 child module
│   ├── compute/
│   │   ├── shared/
│   │   │   └── dc/                          #   Windows Domain Controller
│   │   ├── targets/
│   │   │   ├── linux/                       #   Ubuntu 22.04 SIA target instances
│   │   │   └── windows/                     #   Windows Server 2025 SIA target instances
│   │   └── cyberark/
│   │       ├── linux_connector/             #   Linux SIA connector instances
│   │       └── windows_connector/           #   Windows SIA connector instances
│   └── rds/
│       └── postgres/                        #   PostgreSQL RDS instances
└── cyberark/                                # CyberArk platform configuration
    ├── identity/
    │   ├── users/                           #   Identity user provisioning
    │   └── roles/                           #   Identity role management
    ├── pcloud/
    │   └── safes/                           #   Privilege Cloud safes + role mapping
    └── cmgr/                                #   Connector management (networks/pools)
```

### aws/networking

Creates the foundational AWS networking infrastructure:

- VPC with configurable CIDR
- Public and private subnets across availability zones (including a second private subnet for DB subnet groups)
- Internet Gateway and NAT Gateway
- Route tables with S3 VPC endpoint
- DHCP options for Active Directory domain integration
- VPC peering support
- Database subnet group for RDS

### aws/security

Establishes security controls and access management:

- **Security Groups**: SSH, RDP, WinRM, HTTPS, Jenkins, Domain Controller (AD/DNS), database (MySQL, PostgreSQL, MSSQL), and SIA Windows target access
- **EC2 ASM Role**: Allows EC2 instances to access Secrets Manager and assume roles
- **Secrets Hub Onboarding Role**: Integrates AWS account with CyberArk Secrets Hub
- **Key Pair**: TLS RSA 4096-bit SSH key pair generation with local file storage

### aws/storage

Provides S3-based storage for automation artifacts:

- S3 bucket with public access blocked
- VPC endpoint and trusted IP restrictions

### aws/compute

Deploys EC2 instances across several categories:

**Shared Infrastructure** (`shared/dc/`)
- Windows Server 2025 Domain Controller with static private IP
- IMDSv2 enforcement, encrypted 50GB gp3 root volume

**Target Instances** (`targets/`)
- **Linux** (`targets/linux/`): Ubuntu 22.04 LTS instances in private subnet for SIA targeting
- **Windows** (`targets/windows/`): Windows Server 2025 instances with auto-generated local admin password and user data script

**CyberArk SIA Connectors** (`cyberark/`)
- **Linux Connector** (`cyberark/linux_connector/`): Ubuntu 22.04 LTS instances for SIA access connector
- **Windows Connector** (`cyberark/windows_connector/`): Windows Server 2025 instances for SIA access connector

All compute instances use encrypted gp3 root volumes, IMDSv2 enforcement, and CloudApper scheduling tags.

### aws/rds

Deploys managed database services:

- **PostgreSQL** (`postgres/`): RDS instance with auto-generated admin password, storage encryption, configurable backup retention, and database subnet group placement

### cyberark/identity

Manages CyberArk Identity platform resources:

**Users** (`users/`)
- User creation with email and mobile number
- Configurable domain suffix
- Automated user provisioning from Conjur secrets

**Roles** (`roles/`)
- **User Roles** (5): Windows, Linux, Database, Kubernetes, and Cloud Users
- **Admin Roles** (5): Windows, Linux, Database, Kubernetes, and Cloud Admins
- **Safe Admin Role**: Elevated permissions for safe management
- Naming convention: `{Alias} {Purpose} {Users|Admins}`

### cyberark/pcloud

Manages CyberArk Privilege Cloud resources:

**Safes** (`safes/`) - Creates 13 safes with automated role-to-safe mapping:

| Safe | Short Name | Description |
|------|-----------|-------------|
| PAP-WIN-DOM-SVC | Windows Domain Service | Domain service accounts |
| PAP-WIN-DOM-INT | Windows Domain Interactive | Domain interactive accounts |
| PAP-WIN-DOM-STR | Windows Domain Strong | Domain strong accounts |
| PAP-WIN-LOC-SVC | Windows Local Service | Local service accounts |
| PAP-WIN-LOC-INT | Windows Local Interactive | Local interactive accounts |
| PAP-WIN-LOC-STR | Windows Local Strong | Local strong accounts |
| PAP-NIX-LOC-INT | Linux Local | Local Linux accounts |
| PAP-DB-LOC-INT | Database Local | Local database accounts |
| PAP-DB-LOC-STR | Database Strong | Strong database accounts |
| PAP-CLD-GCP-INT | Cloud GCP | GCP cloud accounts |
| PAP-CLD-AZR-INT | Cloud Azure | Azure cloud accounts |
| PAP-CLD-AWS-INT | Cloud AWS | AWS cloud accounts |
| PAP-K8S-CLS-INT | Kubernetes Cluster | Kubernetes cluster accounts |

**Role-to-Safe Mapping:**
- User roles mapped to matching safes with `connect_only` permissions
- Admin roles mapped to matching safes with `full` permissions
- Safe Admin role mapped to all safes with `full` permissions
- SIA roles (ephemeral and secrets access) mapped to all safes
- Automatic mapping based on safe purpose (WIN, NIX, DB, CLD, K8S)

### cyberark/cmgr

Configures CyberArk Connector Management resources:

- Network and pool configuration for AWS resources
- Pool identifiers based on AWS Account ID and VPC ID

## Deployment

### Step 1: Configure Variables

Each module requires configuration. Create `terraform.tfvars` files or set environment variables for:

- AWS region and account details
- CyberArk tenant URL and credentials
- Project alias (naming prefix)
- Network CIDR ranges
- Trusted IP addresses

### Step 2: Deploy Modules by Dependency Order

Modules must be deployed in dependency order. AWS infrastructure modules first, then CyberArk modules:

```bash
# 1. AWS Networking (foundation - no dependencies)
cd terraform_code/aws/networking
terraform init && terraform plan && terraform apply

# 2. AWS Security (depends on: networking)
cd ../security
terraform init && terraform plan && terraform apply

# 3. AWS Storage (depends on: networking)
cd ../storage
terraform init && terraform plan && terraform apply

# 4. AWS Compute - Domain Controller (depends on: networking, security)
cd ../compute/shared/dc
terraform init && terraform plan && terraform apply

# 5. AWS Compute - Linux Targets (depends on: networking, security)
cd ../../targets/linux
terraform init && terraform plan && terraform apply

# 6. AWS Compute - Windows Targets (depends on: networking, security)
cd ../windows
terraform init && terraform plan && terraform apply

# 7. AWS Compute - Linux SIA Connector (depends on: networking, security)
cd ../../cyberark/linux_connector
terraform init && terraform plan && terraform apply

# 8. AWS Compute - Windows SIA Connector (depends on: networking, security)
cd ../windows_connector
terraform init && terraform plan && terraform apply

# 9. AWS RDS - PostgreSQL (depends on: networking, security)
cd ../../../rds/postgres
terraform init && terraform plan && terraform apply

# 10. CyberArk Identity Users (independent of AWS)
cd ../../../../cyberark/identity/users
terraform init && terraform plan && terraform apply

# 11. CyberArk Identity Roles (depends on: identity/users)
cd ../roles
terraform init && terraform plan && terraform apply

# 12. CyberArk Privilege Cloud Safes (depends on: identity/roles)
cd ../../pcloud/safes
terraform init && terraform plan && terraform apply

# 13. CyberArk CMGR (depends on: networking)
cd ../../cmgr
terraform init && terraform plan && terraform apply
```

### Step 3: Verify Deployment

After deployment, verify:
- AWS resources in the AWS Console
- Security groups and network connectivity
- IAM roles and policies
- CyberArk Identity roles and safes
- EC2 instance accessibility through CyberArk SIA
- RDS database connectivity

## Configuration

### Remote State

All modules use S3-backed remote state for dependency management:
- State files stored in: `s3://bucket-name/terraform/aws/{module}/terraform.tfstate`
- Enables cross-module data sharing via `terraform_remote_state` data sources

### Naming Convention

Resources follow a consistent naming pattern using a project alias:
- AWS resources: lowercase alias (e.g., `papaya-vpc`, `papaya-ubuntu-sia-target-1`)
- CyberArk safes: uppercase prefix format `{PREFIX}-{PLATFORM}-{SCOPE}-{TYPE}` (e.g., `PAP-WIN-DOM-SVC`)
- Identity roles: titlecase (e.g., `Papaya Windows Admins`)

### Security Best Practices

The project implements several security best practices:
- TLS RSA 4096-bit SSH key pair with 0600 permissions
- Encrypted EBS volumes (gp3)
- Restricted security group ingress rules
- Public access blocked on S3 buckets
- VPC endpoint restrictions
- IMDSv2 enforcement on EC2 instances
- Secrets stored in CyberArk Privilege Cloud
- Auto-generated passwords for Windows local admin and RDS

### Tagging Strategy

All resources are tagged with:
- `Name`: Descriptive resource name
- `Project`/`Environment`/`Alias`: Project identifier
- `I_Owner`/`Owner`: Asset owner contact information
- `I_Purpose`: Resource intent
- `CA_iScheduler` / `CA_iSchedulerControl`: CloudApper scheduling tags

## Code Quality

The project includes TFLint configuration for maintaining code quality:

```bash
# Run TFLint
cd terraform_code
tflint --recursive
```

**Enabled Rules:**
- Terraform recommended preset
- AWS plugin checks (v0.45.0)
- Naming convention enforcement (snake_case)

## Technology Stack

- **Infrastructure**: AWS (VPC, EC2, IAM, S3, RDS)
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

1. Follow the existing module structure (`aws/` and `cyberark/` domains)
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
