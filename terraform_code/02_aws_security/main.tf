# =====================================================================
# IAM ROLES
# =====================================================================
module "secrets_hub_onboarding_role" {
  source                        = "./iam_roles/secrets_hub_onboarding_role"
  secrets_manager_region        = var.aws_region
  cyberark_secrets_hub_role_arn = var.cyberark_secrets_hub_role_arn
  alias                         = var.alias
}

module "ec2_asm_role" {
  source = "./iam_roles/ec2_asm_role"
  alias  = var.alias
}

# =====================================================================
# Key Pair
# =====================================================================
module "key_pair" {
  source           = "./key_pair"
  alias            = var.alias
  asset_owner_name = var.asset_owner_name
}