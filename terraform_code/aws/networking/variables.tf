# ===========================
# AWS provider variables
# ===========================
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

# ===========================
# Common Variables
# ===========================
variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}

variable "asset_owner_name" {
  description = "Name of the human that the cloud team can contact with questions"
  type        = string
}

# ===========================
# VPC Variables
# ===========================
variable "private_subnet_az_a" {
  description = "AWS identifier for the private subnet AZ"
  type        = string
  default     = "us-east-2a"
}

variable "private_subnet_az_b" {
  description = "AWS identifier for the private subnet AZ"
  type        = string
  default     = "us-east-2b"
}
variable "peer_owner_id" {
  description = "AWS Account ID of the peer VPC owner"
  type        = string
}

variable "peer_vpc_id" {
  description = "ID of the peer VPC"
  type        = string
}

variable "peer_vpc_cidr" {
  description = "CIDR block of the peer VPC"
  type        = string
}

variable "public_subnet_az" {
  description = "AWS identifier for the public subnet AZ"
  type        = string
  default     = "us-east-2a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for your public subnet"
  type        = string
  default     = "192.168.50.0/24"
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for the private subnet A"
  type        = string
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for the private subnet B"
  type        = string
}
variable "domain_name" {
  description = "Name of the domain to join connectors to"
  type        = string
}

variable "dc1_private_ip" {
  description = "Private IP of DC1 (used as DNS server IP)"
  type        = string
}

