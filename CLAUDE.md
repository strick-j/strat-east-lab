# Claude AI Context - Strat East Lab

This document provides context for Claude AI assistant when working with this repository.

## Repository Overview

**Project Name**: Strat East Lab
**Purpose**: Terraform-based infrastructure-as-code for deploying AWS cloud environment integrated with CyberArk Identity Security and Privileged Access Management (PAM)
**Technology Stack**: Terraform, AWS, CyberArk Identity, CyberArk Privilege Cloud, Conjur

## Project Structure

This project uses a **domain-based modular deployment approach** with two top-level domains (`aws/` and `cyberark/`), each containing hierarchical sub-modules:

```
terraform_code/
├── .tflint.hcl                              # TFLint code quality config
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
│   │   ├── shared/dc/                       #   Windows Domain Controller
│   │   ├── targets/linux/                   #   Ubuntu 22.04 SIA target instances
│   │   ├── targets/windows/                 #   Windows Server 2025 SIA target instances
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

### Module Dependencies

Modules must be deployed respecting their dependency chains:

**AWS Foundation Layer** (deploy first):
1. `aws/networking` — No dependencies (foundation)
2. `aws/security` — Depends on: `aws/networking`
3. `aws/storage` — Depends on: `aws/networking`

**AWS Compute Layer** (depends on foundation):
4. `aws/compute/shared/dc` — Depends on: `aws/networking`, `aws/security`
5. `aws/compute/targets/linux` — Depends on: `aws/networking`, `aws/security`
6. `aws/compute/targets/windows` — Depends on: `aws/networking`, `aws/security`
7. `aws/compute/cyberark/linux_connector` — Depends on: `aws/networking`, `aws/security`
8. `aws/compute/cyberark/windows_connector` — Depends on: `aws/networking`, `aws/security`
9. `aws/rds/postgres` — Depends on: `aws/networking`, `aws/security`

**CyberArk Layer** (sequential):
10. `cyberark/identity/users` — Independent of AWS modules
11. `cyberark/identity/roles` — Depends on: `cyberark/identity/users`
12. `cyberark/pcloud/safes` — Depends on: `cyberark/identity/roles`
13. `cyberark/cmgr` — Depends on: `aws/networking`

## Key Architectural Patterns

### 1. Remote State Management
All modules use S3-backed Terraform remote state:
- State files: `s3://bucket-name/terraform/aws/{module}/terraform.tfstate`
- Enables cross-module data sharing via `terraform_remote_state`
- Backend configuration in each module's `backend.tf` (gitignored)

### 2. Naming Conventions

**Project Alias Pattern**:
- AWS resources: lowercase alias (e.g., `papaya-vpc`, `papaya-ubuntu-sia-target-1`)
- CyberArk safes: uppercase prefix (e.g., `PAP-WIN-DOM-SVC`)
- Identity roles: titlecase with alias (e.g., `Papaya Windows Admins`)

**Safe Naming**: `{PREFIX}-{SHORT_NAME}-{SCOPE}-{TYPE}`
- PREFIX: 3-letter project identifier (PAP, MAN, etc.)
- SHORT_NAME: Platform (WIN, NIX, DB, CLD, K8S)
- SCOPE: Context (DOM, LOC, GCP, AZR, AWS, CLS)
- TYPE: Account type (SVC, INT, STR)

**Role Naming**: `{Alias} {Purpose} {Users|Admins}`
- Examples: "Papaya Windows Users", "Papaya Database Admins"

### 3. Role-to-Safe Mapping (cyberark/pcloud/safes)

**Critical Pattern**: Automatic mapping between Identity roles and Privilege Cloud safes based on purpose matching.

**Mapping Logic**:
```hcl
role_to_safe_mapping = {
  "Windows"  = "WIN"
  "Linux"    = "NIX"
  "Database" = "DB"
  "K8S"      = "K8S"
  "Cloud"    = "CLD"
}
```

**Permission Model**:
- **User Roles** → `connect_only` permissions on matching safes
- **Admin Roles** → `full` permissions on matching safes
- **Safe Admin Role** → `full` permissions on ALL safes
- **SIA Roles** → Mapped to all safes (ephemeral: `read_only`, secrets: `connect_only`)

**Examples**:
- "Papaya Windows Users" maps to: PAP-WIN-DOM-SVC, PAP-WIN-DOM-INT, PAP-WIN-DOM-STR, PAP-WIN-LOC-SVC, PAP-WIN-LOC-INT, PAP-WIN-LOC-STR (all with `connect_only`)
- "Papaya Database Admins" maps to: PAP-DB-LOC-INT, PAP-DB-LOC-STR (both with `full`)

### 4. Compute Instance Patterns

All EC2 instances follow common patterns:
- Encrypted gp3 root volumes
- IMDSv2 enforcement (`http_tokens = "required"`)
- CloudApper scheduling tags (`CA_iScheduler`, `CA_iSchedulerControl`)
- `lifecycle.ignore_changes` for `tags` and `ami` to prevent drift
- Placement in private subnets via `aws/networking` remote state
- Key pair and IAM profile from `aws/security` remote state

**Windows instances** additionally use:
- Auto-generated `random_password` for local admin
- PowerShell user data templates (`scripts/user_data.tpl`)
- Windows Server 2025 Datacenter AMI

**Linux instances** use:
- Ubuntu 22.04 LTS (Jammy) AMI from Canonical

## Important Configuration Files

### Variable Files
Each module has:
- `variables.tf` - Variable definitions
- `default.tfvars` - Default values (contains sensitive data - NOT for production)
- `terraform.tfvars` - User-specific values (gitignored)

### Provider Configuration
Standard providers across modules:
- AWS Provider: ~> 5.36
- CyberArk Identity Security (idsec): ~> 0.1.12
- Conjur Provider: ~> 0.8.1

### Sensitive Data Handling
- Conjur API keys and paths stored in `default.tfvars` (development only)
- Production deployments should use environment variables or secure secret management
- Private keys stored locally at `aws/security/.ssh/default_ssh_key.pem` with 0600 permissions
- Windows admin passwords auto-generated via `random_password` resource

## Common Tasks & Patterns

### Adding a New Safe
1. Edit `terraform_code/cyberark/pcloud/safes/default.tfvars`
2. Add safe definition to `safe_purpose` list with required attributes:
   ```hcl
   {
     description    = "Description of the safe"
     short_name     = "WIN" # WIN, NIX, DB, CLD, K8S
     scope          = "DOM" # DOM, LOC, GCP, AZR, AWS, CLS
     type           = "SVC" # SVC, INT, STR
     retention_days = 0
   }
   ```
3. Role mappings are automatic based on `short_name` matching

### Adding a New Role Purpose
1. Edit `terraform_code/cyberark/identity/roles/default.tfvars`
2. Add purpose to `role_purpose` list (e.g., "Storage")
3. Edit `terraform_code/cyberark/pcloud/safes/main.tf`
4. Add mapping to `locals.role_to_safe_mapping` (e.g., "Storage" = "STR")
5. Creates both User and Admin roles automatically

### Adding a New Compute Module
1. Create directory under appropriate category: `aws/compute/targets/`, `aws/compute/cyberark/`, or `aws/compute/shared/`
2. Add `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`
3. Reference remote state from `aws/networking` and `aws/security`
4. Follow existing instance patterns (encrypted volumes, IMDSv2, scheduling tags)

### Modifying Safe Permissions
Located in `terraform_code/cyberark/pcloud/safes/main.tf`:
- `user_role_mappings` (connect_only)
- `admin_role_mappings` (full)
- `safe_admin_mapping` (full for safe admins)

## Code Quality Standards

### Terraform Standards
- Use `snake_case` for all variables and outputs
- Resources should have descriptive comments in header blocks
- Use `for_each` over `count` for resource iteration
- Always include `description` for variables and outputs

### Git Commit Conventions
Follow Conventional Commits pattern:
- `feat:` - New features or capabilities
- `fix:` - Bug fixes
- `refactor:` - Code restructuring without behavior change
- `docs:` - Documentation updates
- `chore:` - Maintenance tasks

### TFLint
Project includes TFLint configuration:
```bash
tflint --recursive
```
Enabled rules: Terraform recommended, AWS plugin (v0.45.0), snake_case naming

## Common Pitfalls & Solutions

### 1. Module Deployment Order
**Problem**: Applying modules out of order causes errors
**Solution**: Deploy in dependency order. AWS foundation first (networking → security → storage), then compute/RDS, then CyberArk modules

### 2. Remote State Dependencies
**Problem**: Module fails to find outputs from previous module
**Solution**: Ensure previous module's `terraform apply` completed successfully and state file exists in S3

### 3. Role Name Mismatches
**Problem**: Safe member mapping fails with "role not found"
**Solution**: Verify role naming convention matches exactly: `{Alias} {Purpose} {Users|Admins}`

### 4. Safe Purpose Mapping
**Problem**: Roles not mapping to expected safes
**Solution**: Check `short_name` field in safe definition matches key in `role_to_safe_mapping`

### 5. Lifecycle Conflicts
**Problem**: Terraform wants to recreate resources on every apply
**Solution**: Check `lifecycle.ignore_changes` blocks - may need to add attributes that change externally

### 6. Key Pair Path References
**Problem**: Compute modules can't find SSH key
**Solution**: Ensure `aws/security` has been applied and key file exists at `aws/security/.ssh/default_ssh_key.pem`

## Terraform State Management

### State File Locations
- Bucket: Defined in `statefile_bucket_name` variable
- Region: Defined in `aws_region` variable
- Keys: `terraform/aws/{module}/terraform.tfstate` for AWS modules

### State File Dependencies
Compute modules read from networking and security:
```hcl
data "terraform_remote_state" "aws_networking" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.statefile_bucket_name
    key    = "terraform/aws/networking/terraform.tfstate"
  }
}

data "terraform_remote_state" "aws_security" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.statefile_bucket_name
    key    = "terraform/aws/security/terraform.tfstate"
  }
}
```

## Resource Outputs

### Key Outputs by Module
- **aws/networking**: VPC ID, subnet IDs, subnet CIDRs, db subnet group name, S3 VPC endpoint ID, DNS server IP, peer VPC CIDR
- **aws/security**: IAM instance profile name, Secrets Hub role ARN, key pair name, security group IDs (SSH, RDP, WinRM, HTTPS, Jenkins, domain controller, database, SIA, MSSQL)
- **aws/storage**: S3 bucket name, bucket ARN
- **aws/compute/***: Instance IDs, private IPs
- **aws/rds/postgres**: RDS endpoint, database name
- **cyberark/identity/users**: User IDs
- **cyberark/identity/roles**: Role IDs, role names (user_role_ids, admin_role_ids, safe_admin_role_name)
- **cyberark/pcloud/safes**: Safe IDs, safe names
- **cyberark/cmgr**: Connector IDs, pool IDs

## Testing & Validation

### Pre-Deployment Checks
1. Verify AWS credentials: `aws sts get-caller-identity`
2. Check Conjur connectivity: Test API endpoint
3. Validate CyberArk Identity tenant access
4. Ensure S3 bucket exists for state files

### Post-Deployment Validation
1. Check AWS Console for resources
2. Verify CyberArk Identity roles exist
3. Confirm Privilege Cloud safes created
4. Test safe permissions for roles
5. Validate EC2 instance accessibility via SIA
6. Test RDS connectivity from private subnet

### Terraform Commands
```bash
terraform init          # Initialize providers and backend
terraform validate      # Validate syntax
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform output        # Show outputs
terraform state list    # List resources in state
```

## Security Considerations

### Secrets Management
- Conjur API keys in `default.tfvars` are for development only
- Production should use:
  - AWS Secrets Manager
  - Environment variables
  - Conjur host authentication
  - Terraform Cloud variables

### Network Security
- Private subnets require NAT Gateway for internet access
- Security groups follow least-privilege model
- S3 buckets block public access
- VPC endpoints reduce internet exposure
- IMDSv2 required on all EC2 instances

### Access Control
- IAM roles use managed policies where possible
- CyberArk roles follow principle of least privilege
- Safe permissions: Users (connect_only), Admins (full)
- MFA enforcement recommended for interactive accounts

## Support & References

### Documentation
- Terraform Registry: https://registry.terraform.io/
- AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/
- CyberArk Identity Provider: https://registry.terraform.io/providers/cyberark/idsec/

### Common Commands Reference
```bash
# Format all Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan with variable file
terraform plan -var-file="terraform.tfvars"

# Apply with auto-approve (use carefully)
terraform apply -auto-approve

# Destroy specific resource
terraform destroy -target=resource_type.resource_name

# Show state for specific resource
terraform state show resource_type.resource_name

# Import existing resource
terraform import resource_type.resource_name resource_id
```

## AI Assistant Guidelines

When assisting with this repository:

1. **Always respect module dependencies** - Don't suggest applying modules out of order
2. **Maintain naming conventions** - Use established patterns for all resources
3. **Preserve role-to-safe mapping logic** - Don't break the automatic mapping in cyberark/pcloud/safes
4. **Check for remote state references** - Ensure outputs are available before referencing
5. **Follow security best practices** - Don't commit sensitive data, use proper secret management
6. **Test incrementally** - Suggest `terraform plan` before `terraform apply`
7. **Document changes** - Update README.md when modifying module structure
8. **Use conventional commits** - Follow the established git commit message format

## Recent Changes

### Structure Reorganization (2026-02)
- Replaced numbered module structure (01-07) with domain-based hierarchy (`aws/` and `cyberark/`)
- Added new compute sub-modules: `shared/dc`, `targets/windows`, `cyberark/windows_connector`
- Added `aws/rds/postgres` for PostgreSQL RDS instances
- Added `aws/security/key_pair` for centralized SSH key management
- Updated all remote state paths to match new directory structure

### Module Reorganization (2026-01-22)
- Separated identity and safe management into dedicated modules
- Implemented intelligent role-to-safe mapping
- Added Safe Admin role for elevated safe permissions

### Role Mapping Enhancement (2026-01-22)
- Automated User role → Safe mapping with `connect_only` permissions
- Automated Admin role → Safe mapping with `full` permissions
- Safe purpose matching: WIN, NIX, DB, CLD, K8S
- Support for multi-cloud safes (AWS, Azure, GCP)

## License

GNU General Public License v3.0 - See LICENSE file for details
