
data "aws_caller_identity" "current" {}

# =====================================================================
# REMOTE STATE - Foundation Layer
# =====================================================================
data "terraform_remote_state" "aws_foundation" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/aws_foundation.tfstate"
    profile = var.aws_profile
  }
}

# =====================================================================
# CyberArk Identity Security - CMGR Resources
# =====================================================================
resource "idsec_cmgr_network" "cmgr_network" {
  name = "${var.alias}"
}

resource "idsec_cmgr_pool" "cmgr_pool" {
  name                 = "${var.alias}"
  description          = "Pool created by Terraform for Strat East Lab"
  assigned_network_ids = [idsec_cmgr_network.cmgr_network.network_id]
}

resource "idsec_cmgr_pool_identifier" "identifier_1" {
  type    = "AWS_ACCOUNT_ID"
  value   = var.aws_account_id
  pool_id = idsec_cmgr_pool.cmgr_pool.pool_id
}

resource "idsec_cmgr_pool_identifier" "identifier_2" {
  type    = "AWS_VPC"
  value   = data.terraform_remote_state.aws_foundation.outputs.vpc_id
  pool_id = idsec_cmgr_pool.cmgr_pool.pool_id
}

# =====================================================================
# CyberArk Identity Security - Identity Roles
# =====================================================================
resource "idsec_identity_role" "windows_admins" {
  role_name   = "TF ${var.alias} Windows Admins"
  description = "Role for Windows administrators with elevated safe permissions"
}

resource "idsec_identity_role" "windows_users" {
  role_name   = "TF ${var.alias} Windows Users"
  description = "Role for Windows users with standard safe permissions"
}

resource "idsec_identity_role" "linux_admins" {
  role_name   = "TF ${var.alias} Linux Admins"
  description = "Role for Linux administrators with elevated safe permissions"
}

resource "idsec_identity_role" "linux_users" {
  role_name   = "TF ${var.alias} Linux Users"
  description = "Role for Linux users with standard safe permissions"
}

resource "idsec_identity_role" "database_admins" {
  role_name   = "TF ${var.alias} Database Admins"
  description = "Role for Database administrators with elevated safe permissions"
}

resource "idsec_identity_role" "database_users" {
  role_name   = "TF ${var.alias} Database Users"
  description = "Role for Database users with standard safe permissions"
}

data "idsec_identity_role" "sia_ephemeral_role" {
  role_name = "Secure Infrastructure Privilege Cloud Ephemeral Access"
}

data "idsec_identity_role" "sia_access_role" {
  role_name = "DPA RDP Privilege Cloud Secrets Access"
}

# =====================================================================
# CyberArk Privilege Cloud - Safes for Account Storage
# =====================================================================
resource "idsec_pcloud_safe" "windows_accounts_safe" {
  safe_name                    = "TF-${upper(var.alias)}-WINDOWS"
  description                  = "Safe for storing Windows privileged accounts"
  managing_cpm                 = var.managing_cpm
  number_of_versions_retention = 0
}

resource "idsec_pcloud_safe_member" "windows_admins" {
  safe_id        = idsec_pcloud_safe.windows_accounts_safe.safe_id
  member_name    = idsec_identity_role.windows_admins.role_name
  member_type    = "Role"
  permission_set = "full"
}

resource "idsec_pcloud_safe_member" "windows_users" {
  safe_id        = idsec_pcloud_safe.windows_accounts_safe.safe_id
  member_name    = idsec_identity_role.windows_users.role_name
  member_type    = "Role"
  permission_set = "connect_only"
}

resource "idsec_pcloud_safe_member" "windows_sia_ephemeral" {
  safe_id        = idsec_pcloud_safe.windows_accounts_safe.safe_id
  member_name    = data.idsec_identity_role.sia_ephemeral_role.role_name
  member_type    = "Role"
  permission_set = "read_only"
}

resource "idsec_pcloud_safe" "linux_accounts_safe" {
  safe_name                    = "TF-${upper(var.alias)}-LINUX"
  description                  = "Safe for storing Linux privileged accounts"
  managing_cpm                 = var.managing_cpm
  number_of_versions_retention = 0
}

resource "idsec_pcloud_safe_member" "linux_admins" {
  safe_id        = idsec_pcloud_safe.linux_accounts_safe.safe_id
  member_name    = idsec_identity_role.linux_admins.role_name
  member_type    = "Role"
  permission_set = "full"
}

resource "idsec_pcloud_safe_member" "linux_users" {
  safe_id        = idsec_pcloud_safe.linux_accounts_safe.safe_id
  member_name    = idsec_identity_role.linux_users.role_name
  member_type    = "Role"
  permission_set = "connect_only"
}

resource "idsec_pcloud_safe_member" "linux_sia_ephemeral" {
  safe_id        = idsec_pcloud_safe.linux_accounts_safe.safe_id
  member_name    = data.idsec_identity_role.sia_ephemeral_role.role_name
  member_type    = "Role"
  permission_set = "read_only"
}

resource "idsec_pcloud_safe" "database_accounts_safe" {
  safe_name                    = "TF-${upper(var.alias)}-DATABASE"
  description                  = "Safe for storing Database privileged accounts"
  managing_cpm                 = var.managing_cpm
  number_of_versions_retention = 0
}

resource "idsec_pcloud_safe_member" "database_admins" {
  safe_id        = idsec_pcloud_safe.database_accounts_safe.safe_id
  member_name    = idsec_identity_role.database_admins.role_name
  member_type    = "Role"
  permission_set = "full"
}

resource "idsec_pcloud_safe_member" "database_users" {
  safe_id        = idsec_pcloud_safe.database_accounts_safe.safe_id
  member_name    = idsec_identity_role.database_users.role_name
  member_type    = "Role"
  permission_set = "connect_only"
}

resource "idsec_pcloud_safe_member" "database_sia_ephemeral" {
  safe_id        = idsec_pcloud_safe.database_accounts_safe.safe_id
  member_name    = data.idsec_identity_role.sia_ephemeral_role.role_name
  member_type    = "Role"
  permission_set = "read_only"
}
# =====================================================================
# CyberArk Privilege Cloud - Safe for SIA Strong Accounts
# =====================================================================
resource "idsec_pcloud_safe" "stroung_accounts_safe" {
  safe_name                    = "TF-${upper(var.alias)}-SIA"
  description                  = "Safe for storing Database privileged accounts"
  managing_cpm                 = var.managing_cpm
  number_of_versions_retention = 0
}

resource "idsec_pcloud_safe_member" "sia_strong_service_account" {
  safe_id        = idsec_pcloud_safe.stroung_accounts_safe.safe_id 
  member_name    = data.idsec_identity_role.sia_access_role.role_name
  member_type    = "Role"
  permission_set = "read_only" 
}

resource "idsec_pcloud_safe_member" "sia_ephemeral_service_account" {
  safe_id        = idsec_pcloud_safe.stroung_accounts_safe.safe_id 
  member_name    = data.idsec_identity_role.sia_ephemeral_role.role_name
  member_type    = "Role"
  permission_set = "read_only" 
}