# ===========================
# VPC Outputs
# ===========================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}
output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.vpc.public_subnet_id
}
output "private_subnet_id_a" {
  description = "The ID of the private subnet A"
  value       = module.vpc.private_subnet_id_a
}
output "private_subnet_id_b" {
  description = "The ID of the private subnet B"
  value       = module.vpc.private_subnet_id_b
}
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC Gateway Endpoint"
  value       = module.vpc.s3_vpc_endpoint_id
}
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}
output "dns_server_ip" {
  description = "The IP address of the DNS server (domain controller)"
  value       = module.vpc.dns_server_ip
}
output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = module.vpc.db_subnet_group_name
}

# ===========================
# Subnet CIDR Outputs
# ===========================
output "public_subnet_cidr" {
  description = "The CIDR block of the public subnet"
  value       = module.vpc.public_subnet_cidr
} 
output "private_subnet_cidr_a" {
  description = "The CIDR block of the private subnet A"
  value       = module.vpc.private_subnet_cidr_a
}
output "private_subnet_cidr_b" {
  description = "The CIDR block of the private subnet B"
  value       = module.vpc.private_subnet_cidr_b
}
output "peer_vpc_cidr" {
  description = "The CIDR block of the peer VPC"
  value       = module.vpc.peer_vpc_cidr
}