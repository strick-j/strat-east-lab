# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${lower(var.alias)}-vpc"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

resource "aws_vpc_peering_connection" "control_plane_peering" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true

  tags = {
    Name    = "${lower(var.alias)}-vpc-peering-connection"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# DHCP Options Set with custom + AWS DNS
resource "aws_vpc_dhcp_options" "custom_dns" {
  domain_name         = var.domain_name
  domain_name_servers = [var.dns_server_ip, "AmazonProvidedDNS"]

  tags = {
    Name    = "${lower(var.alias)}-dhcp-options"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# Associate DHCP Options with VPC
resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.custom_dns.id
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${lower(var.alias)}-igw"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

#Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = false

  tags = {
    Name    = "${lower(var.alias)}-public-subnet"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# Private Subnet A
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_a
  availability_zone       = var.private_subnet_az_a
  map_public_ip_on_launch = false

  tags = {
    Name    = "${lower(var.alias)}-private-subnet-b"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# Private Subnet B
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_b
  availability_zone       = var.private_subnet_az_b
  map_public_ip_on_launch = false

  tags = {
    Name    = "${lower(var.alias)}-private-subnet-b"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  tags = {
    Name    = "${lower(var.alias)}-nat-eip"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name    = "${lower(var.alias)}-nat-gateway"
    Owner   = var.asset_owner_name
    Project = var.alias
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${lower(var.alias)}-public-rt"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block                = var.peer_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.control_plane_peering.id
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${lower(var.alias)}-private-rt"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  tags              = { Name = "${lower(var.alias)}-s3-gateway-endpoint" }
}

# Create AWS DB Subnet Group
resource "aws_db_subnet_group" "db_sg" {
  name       = "${lower(var.alias)}-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name    = "${lower(var.alias)}-db-subnet-group"
    Owner   = var.asset_owner_name
    Project = var.alias
  }
}
