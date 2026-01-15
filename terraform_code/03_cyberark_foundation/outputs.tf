# ===========================
# Safe Creation Outputs
# ===========================
output "windows_safe_id" {
  description = "The ID of the Windows accounts safe"
  value       = idsec_pcloud_safe.windows_accounts_safe.safe_id
}

output "linux_safe_id" {
  description = "The ID of the Linux accounts safe"
  value       = idsec_pcloud_safe.linux_accounts_safe.safe_id
}

output "database_safe_id" {
  description = "The ID of the Database accounts safe"
  value       = idsec_pcloud_safe.database_accounts_safe.safe_id
}

output "sia_safe_id" {
  description = "The ID of the SIA strong accounts safe"
  value       = idsec_pcloud_safe.stroung_accounts_safe.safe_id
}

# ===========================
# Identity Role Outputs
# ===========================
output "windows_admins_role_id" {
  description = "The ID of the Windows Admins role"
  value       = idsec_identity_role.windows_admins.role_id
}

output "windows_users_role_id" {
  description = "The ID of the Windows Users role"
  value       = idsec_identity_role.windows_users.role_id
}

output "linux_admins_role_id" {
  description = "The ID of the Linux Admins role"
  value       = idsec_identity_role.linux_admins.role_id
}

output "linux_users_role_id" {
  description = "The ID of the Linux Users role"
  value       = idsec_identity_role.linux_users.role_id
}

output "database_admins_role_id" {
  description = "The ID of the Database Admins role"
  value       = idsec_identity_role.database_admins.role_id
}

output "database_users_role_id" {
  description = "The ID of the Database Users role"
  value       = idsec_identity_role.database_users.role_id
}

# ===========================
# CMGR Pool and Network Outputs
# ===========================
output "cmgr_pool_id" {
  description = "The ID of the CMGR pool"
  value       = idsec_cmgr_pool.cmgr_pool.pool_id
}

output "cmgr_network_id" {
  description = "The ID of the CMGR network"
  value       = idsec_cmgr_network.cmgr_network.network_id
}