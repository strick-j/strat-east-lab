# ===========================
# IAM Role Outputs
# ===========================
output "ec2_asm_instance_profile_name" {
  description = "Name of the EC2 ASM instance profile"
  value       = module.ec2_asm_role.ec2_asm_instance_profile_name
}

output "secrets_hub_onboarding_role_arn" {
  description = "ARN of the Secrets Hub onboarding role"
  value       = module.secrets_hub_onboarding_role.role_arn
  sensitive   = true
}

# ===========================
# Key Pair Outputs
# ===========================
output "key_pair_name" {
  description = "The name of the generated key pair"
  value       = module.key_pair.key_pair_name
}

# ===========================
# Security Group Outputs
# ===========================
output "trusted_ssh_external_security_group_id" {
  description = "ID of trusted SSH external security group"
  value       = module.security_groups.trusted_ssh_external_security_group_id
}

output "trusted_rdp_external_security_group_id" {
  description = "ID of trusted RDP external security group"
  value       = module.security_groups.trusted_rdp_external_security_group_id
}

output "ssh_internal_flat_sg_id" {
  description = "ID of SSH internal flat security group"
  value       = module.security_groups.ssh_internal_flat_sg_id
}

output "rdp_internal_flat_sg_id" {
  description = "ID of RDP internal flat security group"
  value       = module.security_groups.rdp_internal_flat_sg_id
}

output "jenkins_8080_flat_sg_id" {
  description = "ID of Jenkins 8080 security group"
  value       = module.security_groups.jenkins_8080_flat_sg_id
}

output "domain_controller_sg_id" {
  description = "ID of domain controller security group"
  value       = module.security_groups.domain_controller_sg_id
}

output "sia_windows_target_sg_id" {
  description = "ID of SIA Windows target security group"
  value       = module.security_groups.sia_windows_target_sg_id
}

output "mysql_target_sg_id" {
  description = "ID of MySQL target security group"
  value       = module.security_groups.mysql_target_sg_id
}

output "postgresql_target_sg_id" {
  description = "ID of PostgreSQL target security group"
  value       = module.security_groups.postgresql_target_sg_id
}

output "winrm_internal_flat_sg_id" {
  description = "ID of WinRM internal flat security group"
  value       = module.security_groups.winrm_internal_flat_sg_id
}

output "oracle_target_sg_id" {
  description = "ID of Oracle target security group"
  value       = module.security_groups.oracle_target_sg_id
}

output "mssql_target_sg_id" {
  description = "ID of MSSQL target security group"
  value       = module.security_groups.mssql_target_sg_id
}

output "https_internal_flat_sg_id" {
  description = "ID of HTTPS internal flat security group"
  value       = module.security_groups.https_internal_flat_sg_id
}
