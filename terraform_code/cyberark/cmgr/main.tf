# =====================================================================
# REMOTE STATE - Foundation Layer
# =====================================================================
data "terraform_remote_state" "aws_foundation" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/aws_foundation.tfstate"
  }
}

# =====================================================================
# CyberArk Identity Security - CMGR Resources
# =====================================================================
resource "idsec_cmgr_network" "cmgr_network" {
  name = var.alias
}

resource "idsec_cmgr_pool" "cmgr_pool" {
  name                 = var.alias
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


