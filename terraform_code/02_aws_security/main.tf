data "aws_caller_identity" "current" {}

# =====================================================================
# REMOTE STATE - Foundation Layer
# =====================================================================
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/aws_foundation.tfstate"
    profile = var.aws_profile
  }
}

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