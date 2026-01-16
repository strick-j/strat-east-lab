variable "asset_owner_name" {
  description = "Name of the asset owner for tagging resources"
  type        = string
}

variable "aws_region" {
  description = "AWS cloud region for the deployment"
  type        = string
}


variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}

variable "private_subnet_az" {
  description = "Availability zone for the private subnet"
  type        = string
}

variable "public_subnet_az" {
  description = "Availability zone for the public subnet"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "domain_name" {
  description = "Domain name for DNS configuration"
  type        = string
}

variable "dns_server_ip" {
  description = "IP address of the DNS server"
  type        = string
}