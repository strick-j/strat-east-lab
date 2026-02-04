output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "arn of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_peering_id" {
  description = "The ID of the VPC Peering Connection"
  value       = aws_vpc_peering_connection.control_plane_peering.id
}

output "peer_vpc_cidr" {
  description = "The CIDR block of the peer VPC"
  value       = var.peer_vpc_cidr
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "public_subnet_cidr" {
  description = "The CIDR block of the public subnet"
  value       = aws_subnet.public.cidr_block
}

output "private_subnet_id_a" {
  description = "The ID of the private subnet A"
  value       = aws_subnet.private_a.id
}

output "private_subnet_id_b" {
  description = "The ID of the private subnet B"
  value       = aws_subnet.private_b.id
}

output "private_subnet_cidr_a" {
  description = "The CIDR block of the private subnet A"
  value       = aws_subnet.private_a.cidr_block
}

output "private_subnet_cidr_b" {
  description = "The CIDR block of the private subnet B"
  value       = aws_subnet.private_b.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_eip" {
  description = "Elastic IP address for the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC Gateway Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "dns_server_ip" {
  description = "The DNS server IP address"
  value       = var.dns_server_ip
}

output "db_subnet_group_name" {
  description = "The RDS DB Subnet Group Name"
  value       = aws_db_subnet_group.db_sg.name
}