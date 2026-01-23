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