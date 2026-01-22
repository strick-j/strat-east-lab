# Claude AI Context - Strat East Lab

This document provides context for Claude AI assistant when working with this repository.

## Repository Overview

**Project Name**: Strat East Lab
**Purpose**: Terraform-based infrastructure-as-code for deploying AWS cloud environment integrated with CyberArk Identity Security and Privileged Access Management (PAM)
**Technology Stack**: Terraform, AWS, CyberArk Identity, CyberArk Privilege Cloud, Conjur

## Project Structure

This project uses a **modular, stage-gated deployment approach** with 7 sequential Terraform modules:

```
terraform_code/
├── 01_aws_foundation/           # AWS VPC, subnets, security groups, S3
├── 02_aws_security/             # IAM roles and policies
├── 03_identity_users/           # CyberArk Identity user provisioning
├── 04_identity_roles/           # CyberArk Identity role management
├── 05_privilege_cloud_safes/    # Privilege Cloud safes + role-to-safe mapping
├── 06_cyberark_foundation/      # CyberArk connector and network config
└── 07_cyberark_compute/         # EC2 instances with SIA connector
```

### Module Dependencies

Modules must be deployed in order due to dependencies:
- Modules 03-07 depend on remote state from previous modules
- Module 05 references role data from module 04 via Terraform remote state
- Module 06 uses outputs from module 01 (AWS Foundation)
- Module 07 depends on outputs from modules 01, 02, and 06

## Key Architectural Patterns

### 1. Remote State Management
All modules use S3-backed Terraform remote state:
- State files: `s3://bucket-name/terraform/{module_name}.tfstate`
- Enables cross-module data sharing via `terraform_remote_state`
- Backend configuration in each module's `backend.tf`

### 2. Naming Conventions

**Project Alias Pattern**:
- AWS resources: lowercase alias (e.g., `papaya-vpc`)
- CyberArk safes: uppercase prefix (e.g., `PAP-WIN-DOM-SVC`)
- Identity roles: titlecase with alias (e.g., `Papaya Windows Admins`)

**Safe Naming**: `{PREFIX}-{SHORT_NAME}-{SCOPE}-{TYPE}`
- PREFIX: 3-letter project identifier (PAP, MAN, etc.)
- SHORT_NAME: Platform (WIN, NIX, DB, CLD, K8S)
- SCOPE: Context (DOM, LOC, GCP, AZR, AWS, CLS)
- TYPE: Account type (SVC, INT, STR)

**Role Naming**: `{Alias} {Purpose} {Users|Admins}`
- Examples: "Papaya Windows Users", "Papaya Database Admins"

### 3. Role-to-Safe Mapping (Module 05)

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

## Important Configuration Files

### Variable Files
Each module has:
- `variables.tf` - Variable definitions
- `default.tfvars` - Default values (contains sensitive data - NOT for production)
- `terraform.tfvars` - User-specific values (gitignored)

### Provider Configuration
Standard providers across modules:
- AWS Provider: ~> 5.36
- CyberArk Identity Security (idsec): ~> 0.1.11+
- Conjur Provider: ~> 0.8.1

### Sensitive Data Handling
- Conjur API keys and paths stored in `default.tfvars` (development only)
- Production deployments should use environment variables or secure secret management
- Private keys stored in CyberArk Privilege Cloud, not local filesystem

## Common Tasks & Patterns

### Adding a New Safe
1. Edit `terraform_code/05_privilege_cloud_safes/default.tfvars`
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
1. Edit `terraform_code/04_identity_roles/default.tfvars`
2. Add purpose to `role_purpose` list (e.g., "Storage")
3. Edit `terraform_code/05_privilege_cloud_safes/main.tf`
4. Add mapping to `locals.role_to_safe_mapping` (e.g., "Storage" = "STR")
5. Creates both User and Admin roles automatically

### Modifying Safe Permissions
Located in `terraform_code/05_privilege_cloud_safes/main.tf`:
- `user_role_mappings` - Line ~107 (connect_only)
- `admin_role_mappings` - Line ~122 (full)
- `safe_admin_mapping` - Line ~43 (full for safe admins)

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

Include "Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" in commit messages when Claude assists.

### TFLint
Project includes TFLint configuration:
```bash
tflint --recursive
```
Enabled rules: Terraform recommended, AWS plugin, snake_case naming

## Common Pitfalls & Solutions

### 1. Module Deployment Order
**Problem**: Applying modules out of order causes errors
**Solution**: Always deploy sequentially: 01 → 02 → 03 → 04 → 05 → 06 → 07

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

## Terraform State Management

### State File Locations
- Bucket: Defined in `statefile_bucket_name` variable
- Region: Defined in `aws_region` variable
- Keys: `terraform/{module_name}.tfstate`

### State File Dependencies
Module 05 reads from module 04:
```hcl
data "terraform_remote_state" "identity_roles" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.statefile_bucket_name
    key    = "terraform/identity_roles.tfstate"
  }
}
```

## Resource Outputs

### Key Outputs by Module
**Module 01**: VPC ID, subnet IDs, security group IDs
**Module 02**: IAM role ARNs
**Module 03**: User IDs
**Module 04**: Role IDs, role names (user_role_ids, admin_role_ids, safe_admin_role_name)
**Module 05**: Safe IDs, safe names
**Module 06**: Connector IDs, pool IDs
**Module 07**: Instance IDs, private IPs

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
3. **Preserve role-to-safe mapping logic** - Don't break the automatic mapping in module 05
4. **Check for remote state references** - Ensure outputs are available before referencing
5. **Follow security best practices** - Don't commit sensitive data, use proper secret management
6. **Test incrementally** - Suggest `terraform plan` before `terraform apply`
7. **Document changes** - Update README.md when modifying module structure
8. **Use conventional commits** - Follow the established git commit message format

## Recent Changes

### Module Reorganization (2026-01-22)
- Separated identity and safe management into dedicated modules (03-05)
- Renumbered CyberArk foundation and compute to 06-07
- Implemented intelligent role-to-safe mapping in module 05
- Added Safe Admin role for elevated safe permissions
- Removed "TF" prefix from role names

### Role Mapping Enhancement (2026-01-22)
- Automated User role → Safe mapping with `connect_only` permissions
- Automated Admin role → Safe mapping with `full` permissions
- Safe purpose matching: WIN, NIX, DB, CLD, K8S
- Support for multi-cloud safes (AWS, Azure, GCP)

## License

GNU General Public License v3.0 - See LICENSE file for details
