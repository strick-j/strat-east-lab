data "aws_caller_identity" "current" {}

module "vpc" {
  source              = "./networking/vpc"
  aws_region          = var.aws_region
  alias               = var.alias
  asset_owner_name    = var.asset_owner_name
  team_name           = var.team_name
  private_subnet_az   = var.private_subnet_az
  public_subnet_az    = var.public_subnet_az
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  domain_name         = var.domain_name
  dns_server_ip       = var.dc1_private_ip
}

module "s3_bucket" {
  source             = "./s3_bucket"
  asset_owner_name   = var.asset_owner_name
  bucket_name        = "${lower(var.alias)}-automation"
  s3_vpc_endpoint_id = module.vpc.s3_vpc_endpoint_id
  aws_region         = var.aws_region
  aws_profile        = var.aws_profile
  trusted_ips        = var.trusted_ips
}

module "security_groups" {
  source              = "./networking/security_groups"
  asset_owner_name    = var.asset_owner_name
  vpc_id              = module.vpc.vpc_id
  trusted_ips         = var.trusted_ips
  alias               = var.alias
  internal_subnets    = ["${var.public_subnet_cidr}", "${var.private_subnet_cidr}"]
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
}
