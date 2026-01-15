data "aws_caller_identity" "current" {}

# =====================================================================
# REMOTE STATE - Foundation Layer
# =====================================================================
data "terraform_remote_state" "foundation" {
  backend = "s3_foundation"
}

# =====================================================================
# IAM ROLES
# =====================================================================
module "secrets_hub_onboarding_role" {
  source                    = "./iam_roles/secrets_hub_onboarding_role"
  SecretsManagerRegion      = var.aws_region
  CyberArkSecretsHubRoleARN = var.CyberArkSecretsHubRoleARN
}

module "ec2_asm_role" {
  source              = "./iam_roles/ec2_asm_role"
  cyberark_secret_arn = [var.cyberark_secret_arn]
}

module "cybr_mcp_server_role" {
  source              = "./iam_roles/cybr_mcp_server_role"
  cyberark_secret_arn = [var.cyberark_secret_arn]
}
