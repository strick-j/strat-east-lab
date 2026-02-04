# =====================================================================
# REMOTE STATE - aws/networking/terraform.tfstate
# =====================================================================
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    region  = var.aws_region
    bucket  = var.statefile_bucket_name
    key     = "terraform/aws/networking/terraform.tfstate"
  }
}

# =====================================================================
# S3 Bucket
# =====================================================================
module "s3_bucket" {
  source             = "./s3"
  alias              = var.alias
  asset_owner_name   = var.asset_owner_name
  bucket_name        = "${lower(var.alias)}-automation"
  s3_vpc_endpoint_id = data.terraform_remote_state.networking.outputs.s3_vpc_endpoint_id
  aws_region         = var.aws_region
  trusted_ips        = var.trusted_ips
}