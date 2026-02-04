# =====================================================================
# CyberArk Identity User Role Creation
# =====================================================================
resource "idsec_identity_role" "admin_roles" {
  for_each    = { for role_purpose in var.role_purpose : role_purpose => role_purpose }
  role_name   = "${var.alias} ${each.value} Admins"
  description = "Role for ${each.value} admins"
}

# =====================================================================
# CyberArk Identity Admin Role Creation
# =====================================================================
resource "idsec_identity_role" "user_roles" {
  for_each    = { for role_purpose in var.role_purpose : role_purpose => role_purpose }
  role_name   = "${var.alias} ${each.value} Users"
  description = "Role for ${each.value} users"
}

# =====================================================================
# CyberArk Privilege Cloud Safe Admin Role Creation
# =====================================================================
resource "idsec_identity_role" "pcloud_safe_admins" {
  role_name   = "${var.alias} Privilege Cloud Safe Admins"
  description = "Role for Privilege Cloud Safe administrators with elevated safe permissions"
}