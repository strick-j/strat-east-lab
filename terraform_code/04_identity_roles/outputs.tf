output "user_role_ids" {
  description = "Map of role keys to their role IDs"
  value       = { for k, v in idsec_identity_role.user_roles : k => v.role_id }
}

output "admin_role_ids" {
  description = "Map of role keys to their admin role IDs"
  value       = { for k, v in idsec_identity_role.admin_roles : k => v.role_id }
}

output "safe_admin_role_id" {
  description = "Role ID for the Privilege Cloud Safe Admin role"
  value       = idsec_identity_role.pcloud_safe_admins.role_id
}

output "safe_admin_role_name" {
  description = "Role Name for the Privilege Cloud Safe Admin role"
  value       = idsec_identity_role.pcloud_safe_admins.role_name
}

