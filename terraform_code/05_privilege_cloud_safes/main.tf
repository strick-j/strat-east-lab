# =====================================================================
# CyberArk Safe Creation
# =====================================================================
resource "idsec_pcloud_safe" "safes" {
  for_each                 = { for safe_purpose in var.safe_purpose : "SAFE-${format("%02d", index(var.safe_purpose, safe_purpose) + 1)}" => safe_purpose }
  safe_name                = (join("-", [var.safe_prefix, each.value.short_name, each.value.scope, each.value.type]))
  description              = each.value.description
  managing_cpm             = var.managing_cpm
  number_of_days_retention = each.value.retention_days
}


# =====================================================================
# Read Required Roles
# =====================================================================
data "idsec_identity_role" "sia_access_role" {
  role_name = "DPA RDP Privilege Cloud Secrets Access"
}

data "idsec_identity_role" "sia_ephemeral_role" {
  role_name = "Secure Infrastructure Privilege Cloud Ephemeral Access"
}

# =====================================================================
# Map Required Roles
# =====================================================================
resource "idsec_pcloud_safe_member" "sia_ephemeral_mapping" {
  for_each       = idsec_pcloud_safe.safes
  safe_id        = each.value.safe_id
  member_name    = data.idsec_identity_role.sia_ephemeral_role.role_name
  member_type    = "Role"
  permission_set = "read_only"
}

resource "idsec_pcloud_safe_member" "safe_access_mapping" {
  for_each       = idsec_pcloud_safe.safes
  safe_id        = each.value.safe_id
  member_name    = data.idsec_identity_role.sia_access_role.role_name
  member_type    = "Role"
  permission_set = "connect_only"
}

resource "idsec_pcloud_safe_member" "safe_admin_mapping" {
  for_each       = idsec_pcloud_safe.safes
  safe_id        = each.value.safe_id
  member_name    = data.terraform_remote_state.identity_roles.outputs.safe_admin_role_name
  member_type    = "Role"
  permission_set = "full"

  depends_on = [data.terraform_remote_state.identity_roles]
}

# =====================================================================
# Remote State - Identity Roles
# =====================================================================
data "terraform_remote_state" "identity_roles" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.statefile_bucket_name
    key    = "terraform/identity_roles.tfstate"
  }
}

# =====================================================================
# Local Variables - Role to Safe Purpose Mapping
# =====================================================================
locals {
  # Mapping between role purpose names and safe short_name prefixes
  role_to_safe_mapping = {
    "Windows"  = "WIN"
    "Linux"    = "NIX"
    "Database" = "DB"
    "K8S"      = "K8S"
    "Cloud"    = "CLD"
  }

  # Create flattened list of user role mappings to safes
  user_role_safe_mappings = flatten([
    for role_purpose, short_name in local.role_to_safe_mapping : [
      for safe_key, safe in idsec_pcloud_safe.safes : {
        map_key      = "${role_purpose}-${safe_key}"
        safe_id      = safe.safe_id
        safe_purpose = var.safe_purpose[index(keys(idsec_pcloud_safe.safes), safe_key)]
        role_purpose = role_purpose
        role_name    = "${var.alias} ${role_purpose} Users"
      } if startswith(var.safe_purpose[index(keys(idsec_pcloud_safe.safes), safe_key)].short_name, short_name)
    ]
  ])

  # Create flattened list of admin role mappings to safes
  admin_role_safe_mappings = flatten([
    for role_purpose, short_name in local.role_to_safe_mapping : [
      for safe_key, safe in idsec_pcloud_safe.safes : {
        map_key      = "${role_purpose}-${safe_key}"
        safe_id      = safe.safe_id
        safe_purpose = var.safe_purpose[index(keys(idsec_pcloud_safe.safes), safe_key)]
        role_purpose = role_purpose
        role_name    = "${var.alias} ${role_purpose} Admins"
      } if startswith(var.safe_purpose[index(keys(idsec_pcloud_safe.safes), safe_key)].short_name, short_name)
    ]
  ])
}

# =====================================================================
# Map User Roles to Safes with Connect Only Permissions
# =====================================================================
resource "idsec_pcloud_safe_member" "user_role_mappings" {
  for_each = { for mapping in local.user_role_safe_mappings : mapping.map_key => mapping }

  safe_id        = each.value.safe_id
  member_name    = each.value.role_name
  member_type    = "Role"
  permission_set = "connect_only"

  depends_on = [data.terraform_remote_state.identity_roles]
}

# =====================================================================
# Map Admin Roles to Safes with Full Permissions
# =====================================================================
resource "idsec_pcloud_safe_member" "admin_role_mappings" {
  for_each = { for mapping in local.admin_role_safe_mappings : mapping.map_key => mapping }

  safe_id        = each.value.safe_id
  member_name    = each.value.role_name
  member_type    = "Role"
  permission_set = "full"

  depends_on = [data.terraform_remote_state.identity_roles]
}