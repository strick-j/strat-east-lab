# =====================================================================
# REMOTE STATE - aws/networking/terraform.tfstate
# =====================================================================
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.statefile_bucket_name
    key    = "terraform/aws/networking/terraform.tfstate"
  }
}

# =====================================================================
# Security Groups
# =====================================================================
module "security_groups" {
  source                = "./security_groups"
  asset_owner_name      = var.asset_owner_name
  vpc_id                = data.terraform_remote_state.networking.outputs.vpc_id
  trusted_ips           = var.trusted_ips
  alias                 = var.alias
  private_subnet_cidr_a = data.terraform_remote_state.networking.outputs.private_subnet_cidr_a
  private_subnet_cidr_b = data.terraform_remote_state.networking.outputs.private_subnet_cidr_b
  internal_subnets = [
    data.terraform_remote_state.networking.outputs.public_subnet_cidr,
    data.terraform_remote_state.networking.outputs.private_subnet_cidr_a,
    data.terraform_remote_state.networking.outputs.private_subnet_cidr_b,
    data.terraform_remote_state.networking.outputs.peer_vpc_cidr
  ]

  depends_on = [data.terraform_remote_state.networking]
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

# =====================================================================
# Key Pair
# =====================================================================
module "key_pair" {
  source           = "./key_pair"
  alias            = var.alias
  asset_owner_name = var.asset_owner_name
}
