# ===========================
# IAM Role Outputs
# ===========================
output "ec2_asm_instance_profile_name" {
  description = "Name of the EC2 ASM instance profile"
  value       = module.ec2_asm_role.us_ent_east_ec2_asm_instance_profile_name
}

output "cybr_mcp_server_instance_profile_name" {
  description = "Name of the CyberArk MCP Server instance profile"
  value       = module.cybr_mcp_server_role.instance_profile_name
}

output "cybr_mcp_server_instance_profile_arn" {
  description = "ARN of the CyberArk MCP Server instance profile"
  value       = module.cybr_mcp_server_role.instance_profile_arn
}

output "cybr_mcp_server_role_arn" {
  description = "ARN of the CyberArk MCP Server IAM role"
  value       = module.cybr_mcp_server_role.role_arn
}

output "cybr_mcp_server_role_name" {
  description = "Name of the CyberArk MCP Server IAM role"
  value       = module.cybr_mcp_server_role.role_name
}

output "secrets_hub_onboarding_role_arn" {
  description = "ARN of the Secrets Hub onboarding role"
  value       = module.secrets_hub_onboarding_role.role_arn
  sensitive   = true
}