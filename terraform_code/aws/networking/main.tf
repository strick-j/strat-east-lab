module "vpc" {
  source                = "./vpc"
  aws_region            = var.aws_region
  alias                 = var.alias
  asset_owner_name      = var.asset_owner_name
  private_subnet_az_a   = var.private_subnet_az_a
  private_subnet_az_b   = var.private_subnet_az_b
  public_subnet_az      = var.public_subnet_az
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidr    = var.public_subnet_cidr
  private_subnet_cidr_a = var.private_subnet_cidr_a
  private_subnet_cidr_b = var.private_subnet_cidr_b
  domain_name           = var.domain_name
  dns_server_ip         = var.dc1_private_ip
  peer_owner_id         = var.peer_owner_id
  peer_vpc_id           = var.peer_vpc_id
  peer_vpc_cidr         = var.peer_vpc_cidr
}
