output "user_role_ids" {
  description = "Map of role keys to their role IDs"
  value       = { for k, v in idsec_identity_role.user_roles : k => v.role_id }
}

output "admin_role_ids" {
  description = "Map of role keys to their admin role IDs"
  value       = { for k, v in idsec_identity_role.admin_roles : k => v.role_id }
}

