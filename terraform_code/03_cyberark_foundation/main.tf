
data "aws_caller_identity" "current" {}

# =====================================================================
# REMOTE STATE - Foundation Layer
# =====================================================================
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/foundation.tfstate"
    profile = var.aws_profile
  }
}

# =====================================================================
# CyberArk Identity Security - CMGR Resources
# =====================================================================
resource "idsec_cmgr_network" "strat_east_network" {
  name = "strat-east-network"
}

resource "idsec_cmgr_pool" "strat_east_pool" {
  name                 = "strat-east-pool"
  description          = "Pool created by Terraform for Strat East Lab"
  assigned_network_ids = [idsec_cmgr_network.strat_east_network.network_id]
}

resource "idsec_cmgr_pool_identifier" "identifier_1" {
  type    = "AWS_ACCOUNT_ID"
  value   = var.aws_account_id
  pool_id = idsec_cmgr_pool.strat_east_pool.pool_id
}

resource "idsec_cmgr_pool_identifier" "identifier_2" {
  type    = "AWS_VPC"
  value   = data.terraform_remote_state.foundation.outputs.vpc_id
  pool_id = idsec_cmgr_pool.strat_east_pool.pool_id
}

# =====================================================================
# CyberArk Identity Security - Identity Roles
# =====================================================================
resource "idsec_identity_role" "windows_admins" {
  role_name   = "Windows-Admins"
  description = "Role for Windows administrators with elevated safe permissions"
}

resource "idsec_identity_role" "windows_users" {
  role_name   = "Windows-Users"
  description = "Role for Windows users with standard safe permissions"
}

resource "idsec_identity_role" "linux_admins" {
  role_name   = "Linux-Admins"
  description = "Role for Linux administrators with elevated safe permissions"
}

resource "idsec_identity_role" "linux_users" {
  role_name   = "Linux-Users"
  description = "Role for Linux users with standard safe permissions"
}

resource "idsec_identity_role" "database_admins" {
  role_name   = "Database-Admins"
  description = "Role for Database administrators with elevated safe permissions"
}

resource "idsec_identity_role" "database_users" {
  role_name   = "Database-Users"
  description = "Role for Database users with standard safe permissions"
}