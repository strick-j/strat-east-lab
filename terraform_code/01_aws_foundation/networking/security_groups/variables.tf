variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "trusted_ips" {
  description = "List of trusted IP addresses for external access"
  type        = list(string)
}

variable "asset_owner_name" {
  description = "Name of the asset owner for tagging resources"
  type        = string
}

variable "internal_subnets" {
  description = "List of internal subnet CIDR blocks for internal security group rules"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  type        = string
}

variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}